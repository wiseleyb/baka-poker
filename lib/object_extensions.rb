module ObjectExtensions
  def sorted_methods
    self.methods.sort - Object.methods
  end
  alias_method :smethods, :sorted_methods

  def metaclass
    class << self; self; end
  end

  def to_bool
    return true if ['1', 'true', 't', 'yes'].include?(self.to_s.downcase.strip)
    false
  end

  def slugify(separator = '-')
    self.downcase
        .squeeze(' ')
        .gsub(/[^a-z0-9']/i, ' ')
        .squeeze(' ')
        .gsub(/[^a-z0-9']/i, separator)
  end

  def is_uuid?
    (self.to_s =~
     /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i) == 0
  end

  def is_number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end

  def possible_phone_number?
    to_s.starts_with?('+') || to_s[0].is_number?
  end
end
Object.send(:include, ObjectExtensions)
