class LetterPicture < HyperComponent
  param :letter

  WORDS = {
    "a" => "Apple", "b" => "Ball", "c" => "Cat", "d" => "Dog", "e" => "Elephant",
    "f" => "Fish", "g" => "Grapes", "h" => "Hat", "i" => "Ice Cream", "j" => "Juice",
    "k" => "Kite", "l" => "Lion", "m" => "Moon", "n" => "Nut", "o" => "Orange",
    "p" => "Penguin", "q" => "Queen", "r" => "Rainbow", "s" => "Sun", "t" => "Tree",
    "u" => "Umbrella", "v" => "Violin", "w" => "Whale", "x" => "X-ray", "y" => "Yo-yo",
    "z" => "Zebra"
  }.freeze

  EMOJI = {
    "a" => "🍎", "b" => "⚽", "c" => "🐱", "d" => "🐶", "e" => "🐘",
    "f" => "🐟", "g" => "🍇", "h" => "🎩", "i" => "🍦", "j" => "🧃",
    "k" => "🪁", "l" => "🦁", "m" => "🌙", "n" => "🥜", "o" => "🍊",
    "p" => "🐧", "q" => "👑", "r" => "🌈", "s" => "☀️", "t" => "🌳",
    "u" => "☂️", "v" => "🎻", "w" => "🐋", "x" => "🩻", "y" => "🪀",
    "z" => "🦓"
  }.freeze

  render do
    DIV(class: "letter-picture") do
      SPAN(class: "letter-picture-emoji") { EMOJI[letter] }
      SPAN(class: "letter-picture-word") { "#{letter.upcase} is for #{WORDS[letter]}" }
    end
  end
end
