function Use-ErmeticAwsAccountQuery([string]$CurrentCursor) {
  return "query {
    AwsAccounts(after:$CurrentCursor) {
        nodes {
            Id
            Name
            Status
            Issues
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