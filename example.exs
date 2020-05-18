alias Vereine.{
  Aggregates.Organization,
  Commands
}

alias Web.{
  OrganizationCache
}

execute_command = fn command ->
  {:ok, _} = Organization.execute(command)
  Organization.get(command.id)
end

# {:ok} = OrganizationCache.start_link()
id = Organization.generate_id()

# OrganizationCache.get(id)

%Commands.SubmitApplication{id: id, name: "test"} |> execute_command.()
%Commands.AddFeature{id: id, feature: :fundable} |> execute_command.()
%Commands.AddFeature{id: id, feature: :employeer} |> execute_command.()
%Commands.FinalizeApplication{id: id} |> execute_command.()
