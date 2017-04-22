defmodule GetAndParseBigJSON do
  @requests  200
  @conn_pool 30

  def main do
    start_main = :os.system_time(:milli_seconds)
    :ok = :hackney_pool.start_pool(:first_pool, [timeout: 100000, max_connections: @conn_pool])
    nginx_host = System.get_env("NGINX_HOST") || "localhost"
    url = "http://#{nginx_host}/citylots.json"

    tasks = for _ <- 1..@requests do
      Task.async(fn ->
        {req, body} = :timer.tc(fn ->
          {:ok, %{body: body, status_code: 200}} =  HTTPoison.get(url, [], hackney: [pool: :first_pool])
          body
        end)

        {parse, data} = :timer.tc(fn ->
          :jiffy.decode(body, [:return_maps])
        end)

        {proc, _} = :timer.tc(fn ->
          counts = Enum.reduce(data["features"], %{}, fn(f,c) ->
            Map.update(c, f["properties"]["FROM_ST"], 0, &(&1 + 1))
          end)
          IO.puts("Some data #{map_size(counts)}")
        end)

        {req/1_000_000, parse/1_000_000, proc/1_000_000}
      end)
    end

    results = for t <- tasks do
      Task.await(t, 1_000_000)
    end

    totals = Enum.reduce(results, {0, 0, 0}, fn(x, acc) ->
      {req, parse, process} = x
      {tot_req, tot_parse, tot_process} = acc
      {tot_req + req, tot_parse + parse, tot_process + process}
    end)
    {req, parse, process} = totals
    total = (:os.system_time(:milli_seconds) - start_main)/1000
    schedulers = :erlang.system_info(:schedulers_online)
    total_timings = %{
      total: total,
      request: req/@conn_pool,
      parse: parse/schedulers,
      process: process/schedulers
    }

    IO.puts("Time spent: #{total_timings.request} request, #{total_timings.parse} parse, #{total_timings.process} process, #{total_timings.total} total")
    {:ok, file} = File.open "#{System.cwd}/results/elixir.json", [:write]
    IO.binwrite(file, :jiffy.encode(total_timings))
    File.close file
  end
end
