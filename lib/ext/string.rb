class String
  def to_xls_col
    return -1 if self.length > 1

    self.upcase[0].ord - 'A'.ord
  end
end