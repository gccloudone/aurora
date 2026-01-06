[
  .data.organization.projectV2.items.nodes[]
  | select(.content != null)
  | select(.content.issueType.name == "Epic")
  | {
      title: .content.title,
      summary: (
        .content.body
        | split("\n\n")
        | map(select(startswith("###") | not))
        | .[0]
      ),
      category: (.fieldValues.nodes[]? | select(.field.name=="Category") | .name),
      client:   (.fieldValues.nodes[]? | select(.field.name=="Client / Partner") | (.text // .name)),
      status:   (.fieldValues.nodes[]? | select(.field.name=="Status") | .name),
      priority: (.fieldValues.nodes[]? | select(.field.name=="Priority") | .name),
      quarter:  (.fieldValues.nodes[]? | select(.field.name=="Quarter") | .title),
      url: .content.url
    }
]
