function Use-ErmeticAwsAccountQuery {
  param ([string]$CurrentCursor)
  return "query {
    AwsAccounts(after:$CurrentCursor) {
        nodes {
            Id
            Name
            Status
            Issues
            ParentScopeId
            Audit
            CreationTime
        }
        pageInfo {
            hasNextPage
            endCursor
        }
    }
  }"
}