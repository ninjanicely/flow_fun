defmodule FlowFun do
  @moduledoc """
  Documentation for FlowFun.
  """

  @doc """
  Hello world.

  ## Examples

      iex> FlowFun.hello()
      :world

  """
  def run do
    MyFlow.start_link([])
  end

end

defmodule MyFlow do

  def start_link(_opts) do
    Flow.from_specs([{ A , 1000 }], [max_demand:  1])
    |> Flow.map(&B.factorial/1)
    #|> Flow.through_specs( [ { {B, []} , []} ] )
    |> Flow.into_specs( [ {C, []} ], [] )
  end

end


defmodule A do
  use GenStage
 
  def start_link(number) do
    GenStage.start_link(A, number)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, counter) when demand > 0 do
    # If the counter is 3 and we ask for 2 items, we will
    # emit the items 3 and 4, and set the state to 5.
    events = Enum.to_list(counter..counter+demand-1)
    {:noreply, events, counter + demand}
  end
end

defmodule B do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(B, :ok)
  end

  def init(:ok) do
    {:producer_consumer, :ok}
  end

  def handle_events(events, _from, :ok) do
    events = Enum.map(events, &factorial/1)
    {:noreply, events, :ok}
  end

  def factorial(0), do: 1
  def factorial(n) when n > 0, do: n * factorial(n - 1)


end

defmodule C do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(C, :ok)
  end

  def init(:ok) do
    {:consumer, :the_state_does_not_matter}
  end

  def handle_events(_events, _from, state) do
    # Inspect the events.
    #IO.inspect(events)

    # We are a consumer, so we would never emit items.
    {:noreply, [], state}
  end
end
