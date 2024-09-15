# deps
Mix.install([
  {:acx, git: "https://github.com/casbin/casbin-ex"},
  :benchee
])

defmodule CB do
  alias Acx.EnforcerSupervisor
  alias Acx.EnforcerServer

  @acl_name "blog_acl"
  @rbac_name "blog_rbac"

  # setup server
  def init do
    # {:ok, _pid} = EnforcerSupervisor.start_enforcer(@acl_name, "./blog_ac.conf")
    # :ok = EnforcerServer.load_policies(@acl_name, "./blog_ac.csv")

    {:ok, _pid} = EnforcerSupervisor.start_enforcer(@rbac_name, "./#{@rbac_name}.conf")
    :ok = EnforcerServer.load_policies(@rbac_name, "./#{@rbac_name}.csv")
    :ok = EnforcerServer.load_mapping_policies(@rbac_name, "./#{@rbac_name}.csv")
  end

  def acl_example do
    req = ["alice", "blog_post", "read"]

    req |> acl_allow?() |> dbg()
  end

  def rbac_example do
    req = ["alice", "blog_post", "read"]

    req |> rbac_allow?() |> dbg()
  end

  def acl_allow?(req) do
    EnforcerServer.allow?(@acl_name, req)
  end

  def rbac_allow?(req) do
    EnforcerServer.allow?(@rbac_name, req)
  end

  def bench do
    Benchee.run(
      %{
        acl_all_found: fn -> EnforcerServer.allow?(@acl_name, ["alice", "blog_post", "read"]) end,
        acl_not_found_subject: fn -> EnforcerServer.allow?(@acl_name, ["bob", "fake", "read"]) end,
        acl_not_found_user: fn -> EnforcerServer.allow?(@acl_name, ["bob", "fake", "read"]) end,
        rbac_all_found: fn ->
          EnforcerServer.allow?(@rbac_name, ["alice", "blog_post", "read"])
        end,
        rbac_not_found_subject: fn ->
          EnforcerServer.allow?(@rbac_name, ["bob", "fake", "read"])
        end,
        rbac_not_found_user: fn -> EnforcerServer.allow?(@rbac_name, ["bob", "fake", "read"]) end
      },
      warmup: 2,
      parallel: 100
    )

    :ok
  end
end

CB.init()
