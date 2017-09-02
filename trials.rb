counter1 = 0
counter2 = 0

def tracker(x, y)
    x + 1
    y + 1
end

loop do
    counter1 += tracker(counter1, counter2)
    break if counter1 == 15
end

p counter1
p counter2