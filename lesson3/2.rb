class Pets
  def speak
    'bark!'
  end

  def run
    'running!'
  end

  def jump
    'jumping!'
  end
end
  
class Dog < Pets

  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end
end

class Cat < Pets 
  def speak
    'meow'
  end
end
  
kitty = Cat.new
p kitty.speak

frank = Dog.new
p frank.speak

# Pets
# Dog - Cat