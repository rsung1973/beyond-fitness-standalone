using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebHome.Security.Authorization
{
    internal class RoleBaseAuthorizationHandler : AuthorizationHandler<RoleBaseRequirement>
    {
        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, RoleBaseRequirement requirement)
        {
            throw new NotImplementedException();
        }
    }
}
