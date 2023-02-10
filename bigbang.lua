-- bigbang

engine.name="BigBang"

function init()

  redraw()
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center("big bang")
  screen.update()
end
