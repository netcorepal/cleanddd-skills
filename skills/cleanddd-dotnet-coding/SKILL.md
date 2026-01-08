---
name: cleanddd-dotnet-coding
description: 指导如何在 CleanDDD 项目中根据建模结果编写代码的技能
---

## 使用时机
- 在本仓库编写/修改业务功能、命令、查询、端点、集成事件、仓储、实体配置或相关测试时加载。

## Required inputs

- 建模设计：已完成 CleanDDD 需求分析与建模，获得聚合、命令、查询、事件等设计文档。

## 通用原则
- 优先用主构造函数，所有 IO/仓储/EF 调用使用 async/await 并传递 CancellationToken。
- 严格分层：Web → Infrastructure → Domain；聚合与实体发布领域事件，命令处理器不显式 SaveChanges。
- 强类型 ID 由 EF 值生成器提供；构造函数不设置 ID，直接使用类型实例，避免 .Value。
- 业务异常使用 KnownException；FastEndpoints 用特性配置，不使用 Configure()；IMediator 构造注入，使用 Send.OkAsync/CreatedAsync/NoContentAsync 与 .AsResponseData()。

## 推荐工作流
1) 聚合与实体 → 2) 领域事件 → 3) 仓储与实体配置 → 4) 命令+验证器+处理器 → 5) 查询+验证器+处理器 → 6) Endpoints → 7) 领域事件处理器 → 8) 集成事件/转换器/处理器 → 9) 测试。

## 目录定位
- Domain：src/ProjectName.Domain/（AggregatesModel/{Aggregate}Aggregate，DomainEvents）。
- Infrastructure：src/ProjectName.Infrastructure/（Repositories，EntityConfigurations，ApplicationDbContext）。
- Web：src/ProjectName.Web/Application/（Commands，Queries，DomainEventHandlers，IntegrationEvents，IntegrationEventConverters，IntegrationEventHandlers）；Endpoints。
- Tests：test/* 对应各层。

## 聚合
- 聚合根：继承 Entity<TId> + IAggregateRoot，protected 无参构造；属性 private set，默认值显式设置；状态变更时 this.AddDomainEvent()；包含 Deleted 与 RowVersion；每聚合仅一个根，命名无需 Aggregate 后缀。
- 强类型 ID：public partial record，命名 {Entity}Id，与聚合同文件；实现 IGuidStronglyTypedId（优先）或 IInt64StronglyTypedId，依赖 EF 值生成，不手动赋值。
- 子实体：public，强类型 ID，继承 Entity<TId> + IEntity，需无参构造。
- 放置：src/ProjectName.Domain/AggregatesModel/{Aggregate}Aggregate/{Entity}.cs。

示例：User 聚合根与强类型 ID
```csharp
namespace ProjectName.Domain.AggregatesModel.UserAggregate;

public partial record UserId : IGuidStronglyTypedId;

public class User : Entity<UserId>, IAggregateRoot
{
    protected User() { }

    public User(string name, string email)
    {
        Name = name;
        Email = email;
        this.AddDomainEvent(new UserCreatedDomainEvent(this));
    }

    public string Name { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public Deleted Deleted { get; private set; } = new();
    public RowVersion RowVersion { get; private set; } = new(0);

    public void ChangeEmail(string email)
    {
        Email = email;
        this.AddDomainEvent(new UserEmailChangedDomainEvent(this));
    }
}
```

## 领域事件
- record + IDomainEvent；命名 {Entity}{Action}DomainEvent（过去式）；无逻辑，仅载体。文件位于 DomainEvents/{Aggregate}DomainEvents.cs，可含多个事件。

示例：User 领域事件
```csharp
namespace ProjectName.Domain.DomainEvents;

public record UserCreatedDomainEvent(User User) : IDomainEvent;
public record UserEmailChangedDomainEvent(User User) : IDomainEvent;
```

## 命令
- record 定义；无返回 ICommand，有返回 ICommand<TResponse>；每个命令需 AbstractValidator<TCommand>。处理器实现 ICommandHandler，仓储读取聚合；全异步，传递 CancellationToken；KnownException 表达业务异常；不手动 SaveChanges/UpdateAsync。
- 文件：Web/Application/Commands/{Module}s/{Action}{Entity}Command.cs，命令+验证器+处理器同文件。

示例：创建用户命令
```csharp
using ProjectName.Domain.AggregatesModel.UserAggregate;

namespace ProjectName.Web.Application.Commands.Users;

public record CreateUserCommand(string Name, string Email) : ICommand<UserId>;

public class CreateUserCommandValidator : AbstractValidator<CreateUserCommand>
{
    public CreateUserCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(50);
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(100);
    }
}

public class CreateUserCommandHandler(IUserRepository userRepository)
    : ICommandHandler<CreateUserCommand, UserId>
{
    public async Task<UserId> Handle(CreateUserCommand command, CancellationToken cancellationToken)
    {
        if (await userRepository.EmailExistsAsync(command.Email, cancellationToken))
            throw new KnownException("邮箱已存在");

        var user = new User(command.Name, command.Email);
        await userRepository.AddAsync(user, cancellationToken);
        return user.Id;
    }
}
```

## 查询
- record + IQuery<T>/IPagedQuery<T>；每个查询需 AbstractValidator<TQuery>。处理器实现 IQueryHandler，直接用 ApplicationDbContext 查询；异步 + CancellationToken；使用投影、WhereIf/OrderByIf/ToPagedDataAsync；分页用 PagedData<T>，提供默认排序。
- 禁用仓储和跨聚合 Join；无副作用。放置 Web/Application/Queries/{Module}s/{Action}{Entity}Query.cs（含 DTO/验证器/处理器）。

示例：查询用户
```csharp
using ProjectName.Domain.AggregatesModel.UserAggregate;
using ProjectName.Infrastructure;
using Microsoft.EntityFrameworkCore;

namespace ProjectName.Web.Application.Queries.Users;

public record GetUserQuery(UserId UserId) : IQuery<UserDto>;

public class GetUserQueryValidator : AbstractValidator<GetUserQuery>
{
    public GetUserQueryValidator()
    {
        RuleFor(x => x.UserId).NotEmpty();
    }
}

public class GetUserQueryHandler(ApplicationDbContext context)
    : IQueryHandler<GetUserQuery, UserDto>
{
    public async Task<UserDto> Handle(GetUserQuery request, CancellationToken cancellationToken)
    {
        return await context.Users
            .Where(x => x.Id == request.UserId)
            .Select(x => new UserDto(x.Id, x.Name, x.Email))
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new KnownException($"未找到用户，UserId = {request.UserId}");
    }
}

public record UserDto(UserId Id, string Name, string Email);
```

## Endpoints
- 每文件单 Endpoint，继承相应基类；请求/响应 DTO 同文件，使用 ResponseData<T> 包装。
- 使用属性路由/权限（[HttpPost]/[AllowAnonymous]/[Tags]）；HandleAsync 内通过 mediator 发送命令/查询；Send.OkAsync/CreatedAsync/NoContentAsync + .AsResponseData()。
- DTO 可直接用强类型 ID；避免 .Value；不使用 Configure()。位置：Web/Endpoints/{Module}/{Action}{Entity}Endpoint.cs。

示例：创建用户 Endpoint
```csharp
using ProjectName.Domain.AggregatesModel.UserAggregate;
using ProjectName.Web.Application.Commands.Users;
using Microsoft.AspNetCore.Authorization;

namespace ProjectName.Web.Endpoints.Users;

public record CreateUserRequest(string Name, string Email);
public record CreateUserResponse(UserId UserId);

[Tags("Users")]
[HttpPost("/api/users")]
[AllowAnonymous]
public class CreateUserEndpoint(IMediator mediator)
    : Endpoint<CreateUserRequest, ResponseData<CreateUserResponse>>
{
    public override async Task HandleAsync(CreateUserRequest req, CancellationToken ct)
    {
        var id = await mediator.Send(new CreateUserCommand(req.Name, req.Email), ct);
        await Send.OkAsync(new CreateUserResponse(id).AsResponseData(), ct);
    }
}
```

## 领域事件处理器
- 实现 IDomainEventHandler<T>，方法签名 Handle(TEvent, CancellationToken)；主构造函数注入依赖；文件仅一个处理器。
- 命名 {DomainEvent}DomainEventHandlerFor{Action}；通过 mediator 发送命令驱动聚合，不直接改 Db；遵守事务/取消。
- 位置：Web/Application/DomainEventHandlers/{Name}.cs。

示例：领域事件处理器触发命令
```csharp
using ProjectName.Domain.DomainEvents;
using ProjectName.Web.Application.Commands.Users;

namespace ProjectName.Web.Application.DomainEventHandlers;

public class UserCreatedDomainEventHandlerForSendWelcome(IMediator mediator)
    : IDomainEventHandler<UserCreatedDomainEvent>
{
    public async Task Handle(UserCreatedDomainEvent domainEvent, CancellationToken cancellationToken)
    {
        var command = new SendWelcomeEmailCommand(domainEvent.User.Id, domainEvent.User.Email, domainEvent.User.Name);
        await mediator.Send(command, cancellationToken);
    }
}
```

## 仓储
- 每聚合一个仓储：接口继承 IRepository<TEntity,TKey>，实现继承 RepositoryBase<TEntity,TKey,ApplicationDbContext>；接口与实现同文件，文件名 {Aggregate}Repository.cs。
- DbContext 属性访问 DbSet；默认基类方法已提供，勿重复；自动注册依赖注入。

示例：用户仓储
```csharp
using ProjectName.Domain.AggregatesModel.UserAggregate;

namespace ProjectName.Infrastructure.Repositories;

public interface IUserRepository : IRepository<User, UserId>
{
    Task<bool> EmailExistsAsync(string email, CancellationToken cancellationToken = default);
}

public class UserRepository(ApplicationDbContext context)
    : RepositoryBase<User, UserId, ApplicationDbContext>(context), IUserRepository
{
    public async Task<bool> EmailExistsAsync(string email, CancellationToken cancellationToken = default)
    {
        return await DbContext.Users.AnyAsync(x => x.Email == email, cancellationToken);
    }
}
```

## 实体配置
- 每实体一个配置，实现 IEntityTypeConfiguration<T>；文件 {Entity}EntityTypeConfiguration.cs，放 Infrastructure/EntityConfigurations。
- 必须配置主键；字符串设 MaxLength；必填 IsRequired；所有字段给注释；按需要加索引。
- 强类型 ID：IGuidStronglyTypedId → UseGuidVersion7ValueGenerator；IInt64StronglyTypedId → UseSnowFlakeValueGenerator；不要自定义转换器；RowVersion 无需配置。

示例：用户实体配置
```csharp
using ProjectName.Domain.AggregatesModel.UserAggregate;

namespace ProjectName.Infrastructure.EntityConfigurations;

public class UserEntityTypeConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .UseGuidVersion7ValueGenerator()
            .HasComment("用户标识");

        builder.Property(x => x.Name)
            .IsRequired()
            .HasMaxLength(50)
            .HasComment("用户姓名");

        builder.Property(x => x.Email)
            .IsRequired()
            .HasMaxLength(100)
            .HasComment("用户邮箱");

        builder.HasIndex(x => x.Email).IsUnique();
    }
}
```

## DbContext
- 在 ApplicationDbContext 添加聚合命名空间与 DbSet => Set<T>(); 默认 ApplyConfigurationsFromAssembly，无需手动注册。文件 Infrastructure/ApplicationDbContext.cs。

示例：DbSet 注册
```csharp
using ProjectName.Domain.AggregatesModel.UserAggregate;

namespace ProjectName.Infrastructure;

public partial class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options, IMediator mediator)
    : AppDbContextBase(options, mediator)
{
    public DbSet<User> Users => Set<User>();
}
```

## 集成事件
- record，不可变，描述已发生事件；无聚合引用，避免敏感信息；文件 {Entity}{Action}IntegrationEvent.cs，目录 Web/Application/IntegrationEvents；复杂类型同文件也用 record。

示例：用户创建集成事件
```csharp
using ProjectName.Domain.AggregatesModel.UserAggregate;

namespace ProjectName.Web.Application.IntegrationEvents;

public record UserCreatedIntegrationEvent(UserId UserId, string Name, string Email, DateTime CreatedTime);
```

## 集成事件转换器
- 实现 IIntegrationEventConverter<TDomainEvent,TIntegrationEvent>，将领域事件转为集成事件；record 事件。文件 {Entity}{Action}IntegrationEventConverter.cs，目录 Web/Application/IntegrationEventConverters；自动注册。

示例：领域事件到集成事件
```csharp
using ProjectName.Domain.DomainEvents;
using ProjectName.Web.Application.IntegrationEvents;

namespace ProjectName.Web.Application.IntegrationEventConverters;

public class UserCreatedIntegrationEventConverter
    : IIntegrationEventConverter<UserCreatedDomainEvent, UserCreatedIntegrationEvent>
{
    public UserCreatedIntegrationEvent Convert(UserCreatedDomainEvent domainEvent)
    {
        var user = domainEvent.User;
        return new UserCreatedIntegrationEvent(user.Id, user.Name, user.Email, DateTime.UtcNow);
    }
}
```

## 集成事件处理器
- 实现 IIntegrationEventHandler<T>，HandleAsync(T, CancellationToken)；主构造函数注入依赖；文件单一处理器，命名 {IntegrationEvent}HandlerFor{Action}，通过命令操作聚合，不直接改 Db。目录 Web/Application/IntegrationEventHandlers。

示例：处理集成事件
```csharp
using ProjectName.Web.Application.Commands.Users;
using ProjectName.Web.Application.IntegrationEvents;

namespace ProjectName.Web.Application.IntegrationEventHandlers;

public class UserCreatedIntegrationEventHandlerForSendWelcomeEmail(
    ILogger<UserCreatedIntegrationEventHandlerForSendWelcomeEmail> logger,
    IMediator mediator)
    : IIntegrationEventHandler<UserCreatedIntegrationEvent>
{
    public async Task HandleAsync(UserCreatedIntegrationEvent integrationEvent, CancellationToken cancellationToken)
    {
        logger.LogInformation("发送欢迎邮件：{UserId}", integrationEvent.UserId);
        var command = new SendWelcomeEmailCommand(integrationEvent.UserId, integrationEvent.Email, integrationEvent.Name);
        await mediator.Send(command, cancellationToken);
    }
}
```

## 单元测试
- AAA 模式；单测单场景；覆盖正常+异常、领域事件、状态/不变量、边界；命名 {Method}_{Scenario}_{Expected}。
- 使用 Theory/InlineData；强类型 ID 直接 new 比较；时间使用 >= 等相对比较。
- 领域事件使用 GetDomainEvents() 校验类型/数量；可用工厂/Builder 生成测试数据。
- 位置：test/ProjectName.Domain.Tests/{Entity}Tests.cs；Infrastructure/Web 类似；遵循强类型 ID、KnownException 检查。

示例：聚合单测
```csharp
public class UserTests
{
    [Fact]
    public void Constructor_ShouldRaiseCreatedEvent()
    {
        var user = new User("Alice", "alice@example.com");

        Assert.Equal("Alice", user.Name);
        Assert.Single(user.GetDomainEvents());
        Assert.IsType<UserCreatedDomainEvent>(user.GetDomainEvents().First());
    }

    [Fact]
    public void ChangeEmail_ShouldRaiseChangedEvent()
    {
        var user = new User("Bob", "old@example.com");
        user.ClearDomainEvents();

        user.ChangeEmail("new@example.com");

        Assert.Equal("new@example.com", user.Email);
        Assert.IsType<UserEmailChangedDomainEvent>(user.GetDomainEvents().Single());
    }
}
```

## KnownException 参考
```csharp
if (Paid) throw new KnownException("Order has been paid");
var order = await orderRepository.GetAsync(request.OrderId, cancellationToken)
             ?? throw new KnownException($"未找到订单，OrderId = {request.OrderId}");
order.OrderPaid();
```

## 常用 using 提示
- Web 全局：global using FluentValidation; MediatR; NetCorePal.Extensions.Primitives; FastEndpoints; NetCorePal.Extensions.Dto; NetCorePal.Extensions.Domain。
- Infrastructure 全局：global using Microsoft.EntityFrameworkCore; Microsoft.EntityFrameworkCore.Metadata.Builders; NetCorePal.Extensions.Primitives。
- Domain 全局：global using NetCorePal.Extensions.Domain; NetCorePal.Extensions.Primitives。
- Tests 全局：global using Xunit; NetCorePal.Extensions.Primitives。
- 额外：查询处理器需引用聚合命名空间与 Infrastructure；实体配置需引用对应聚合；端点需引用聚合、命令、查询命名空间。
