using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebHome.Security.Authorization
{
    internal class RoleBasePolicyProvider : IAuthorizationPolicyProvider
    {
        public const string POLICY = "UserRoleAuth";

        public DefaultAuthorizationPolicyProvider FallbackPolicyProvider { get; }

        public RoleBasePolicyProvider(IOptions<AuthorizationOptions> options)
        {
            FallbackPolicyProvider = new DefaultAuthorizationPolicyProvider(options);
        }
        public Task<AuthorizationPolicy> GetDefaultPolicyAsync() => FallbackPolicyProvider.GetDefaultPolicyAsync();

        public Task<AuthorizationPolicy> GetFallbackPolicyAsync() => FallbackPolicyProvider.GetFallbackPolicyAsync();

        public Task<AuthorizationPolicy> GetPolicyAsync(string policyName)
        {
            if (policyName == POLICY)
            {
                var policy = new AuthorizationPolicyBuilder();
                policy.AddRequirements(new RoleBaseRequirement { });
                return Task.FromResult(policy.Build());
            }

            return FallbackPolicyProvider.GetPolicyAsync(policyName);
        }

    }
}
