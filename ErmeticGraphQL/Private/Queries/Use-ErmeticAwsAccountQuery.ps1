function Use-ErmeticAwsAccountQuery {
  param (
    [string]$CurrentCursor,
    [int] $First = 1000
  )
  return "query {
    AwsAccounts(after:$CurrentCursor, first:$First) {
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