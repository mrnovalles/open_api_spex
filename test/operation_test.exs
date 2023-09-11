defmodule OpenApiSpex.OperationTest do
  use ExUnit.Case
  alias OpenApiSpexTest.Schemas
  alias OpenApiSpex.Operation
  alias OpenApiSpexTest.UserController

  describe "Operation" do
    test "from_route %Phoenix.Router.Route{}" do
      plug = UserController
      plug_opts = :show

      route =
        Phoenix.Router.Route.build(
          _line = nil,
          _kind = :match,
          _verb = :atom,
          _path = nil,
          _host = nil,
          plug,
          plug_opts,
          _helper = nil,
          _pipe_through = [],
          _private = %{},
          _assigns = %{},
          _metadata = %{},
          _trailing_slash? = false
        )

      assert Operation.from_route(route) ==
               UserController.open_api_operation(:show)
    end

    test "from_route ~ phoenix v1.4.7+" do
      route = %{plug: UserController, plug_opts: :show}

      assert Operation.from_route(route) ==
               UserController.open_api_operation(:show)
    end

    test "from_plug" do
      assert Operation.from_plug(UserController, :show) ==
               UserController.open_api_operation(:show)
    end

    test "response" do
      assert %OpenApiSpex.Response{} =
               Operation.response(
                 "A description for the response",
                 "application/json",
                 Schemas.User.schema().example
               )

      assert %OpenApiSpex.Response{} =
               Operation.response(
                 "A description for the response",
                 "application/json",
                 Schemas.User.schema().example,
                 headers: %{
                   "content-length" => %OpenApiSpex.Header{
                     description: "The length of response",
                     example: "content-length: 42"
                   }
                 }
               )
    end

    test "parameter" do
      assert %OpenApiSpex.Parameter{
               name: :some_param,
               in: :query,
               description: "A string param description",
               required: false,
               schema: %OpenApiSpex.Schema{type: :string}
             } = Operation.parameter(:some_param, :query, :string, "A string param description")

      assert %OpenApiSpex.Parameter{
               name: :some_param,
               in: :query,
               description: "A string param description",
               required: false,
               schema: %OpenApiSpex.Schema{enum: ["foo", "bar"], type: :string}
             } =
               Operation.parameter(:some_param, :query, :string, "A string param description",
                 schema: %OpenApiSpex.Schema{type: :string, enum: ["foo", "bar"]}
               )
    end
  end
end
