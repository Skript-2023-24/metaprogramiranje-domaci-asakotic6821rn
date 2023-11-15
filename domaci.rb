require 'google_drive'

class Nekaklasa
  include Enumerable
  attr_accessor(:spreadsheet_key, :worksheet_title, :worksheet, :mat_kolone, :mat_redovi)

  def initialize(spreadsheet_key, worksheet_title)
    @spreadsheet_key = spreadsheet_key
    @worksheet_title = worksheet_title
  end

  def connect
    session = GoogleDrive::Session.from_config('config.json')
    spreadsheet = session.spreadsheet_by_key(spreadsheet_key)
    worksheet = spreadsheet.worksheet_by_title(worksheet_title)
  end

  def row(i)
    @mat_redovi[i]
  end

  def ucitaj_matricu(worksheet)
    prvi = nil
    (1..worksheet.num_rows).each do |i|
      (1..worksheet.num_cols).each do |j|
        prvi = [i, j] unless worksheet[i, j].empty?
        break if prvi
      end
      break if prvi
    end

    mat = []
    (prvi[0]..worksheet.num_rows).each do |i|
      red = []
      (prvi[1]..worksheet.num_cols).each do |j|
        red << worksheet[i, j]
      end
      mat << red unless (red.to_s.downcase.include? 'total') || (red.to_s.downcase.include? 'subtotal')
    end
    mat_redovi = mat
    mat = mat.transpose
    mat_kolone = mat
  end

  def each
    mat_redovi.each do |red|
      red.each do |e|
        yield e
      end
    end
  end

  def [](str)
    mat_kolone.each_with_index do |kolona, index|
      return NovaKlasa.new(kolona, self, index) if kolona[0].delete(' ') == str.delete(' ')
    end
    nil
  end

  def method_missing(ime, *args)
    raise 'ne sme da ima argumente!' unless args.empty?

    ime = ime.to_s
    self[ime]
  end

  def +(other)
    raise 'nisu ista zaglavlja' unless mat_redovi[0] == other.mat_redovi[0]

    res = []
    mat_redovi.each do |red|
      res << red
    end
    other.mat_redovi.each_with_index do |red, index|
      res << red unless index == 0
    end
    res
  end

  def -(other)
    mat_redovi.filter.with_index do |red, index|
      index == 0 || !other.mat_redovi.include?(red)
    end
  end
end

class NovaKlasa
  include Enumerable

  attr_accessor(:niz, :klasa, :index)

  def initialize(niz, klasa, index)
    @niz = niz
    @klasa = klasa
    @index = index
  end

  def [](br)
    @niz[br]
  end

  def []=(br, setuj)
    @niz[br] = setuj
  end

  def to_s
    @niz.to_s
  end

  def sum
    @niz.map(&:to_i).reduce(&:+)
  end

  def avg
    self.sum / (@niz.length - 1).to_f
  end

  def method_missing(ime, *args)
    raise 'ne sme da ima argumente!' unless args.empty?

    ime = ime.to_s
    klasa.mat_redovi.each do |red|
      return red if red[index] == ime
    end
    nil
  end

  def each
    @niz.each do |x|
        yield x
    end
  end
end

t = Nekaklasa.new('1Eb0lYATYg10apDvKXSi9woS61Hj8XfrL5h4mxLzy6cM', 'Sheet1')
t.connect
t.ucitaj_matricu(t.worksheet)

t2 = Nekaklasa.new('1Eb0lYATYg10apDvKXSi9woS61Hj8XfrL5h4mxLzy6cM', 'Sheet2')
t2.connect
t2.ucitaj_matricu(t2.worksheet)

# 2.
# p t.row(0)

# 3.
# t.each do |x|
#     p x
# end

# 5.
# puts t["Prva Kolona"]

# 5.2
# t["Prva Kolona"][3] = 100
# puts t["Prva Kolona"][3]

# 5.3
# p t.Index.re3

# 6
# puts t.PrvaKolona

# 6.2
# puts t.PrvaKolona.sum

# 6.3
# p( t.PrvaKolona.map &:upcase)
# p t.PrvaKolona.select {|x| x.length>1}
# p t.PrvaKolona.reduce &:+
# p t2.mat_redovi[4].reduce &:+

p t.mat_kolone
p t2.mat_kolone

# 7. ne ukljucuje se total

# 8.
# rez = t+t2
# p rez

# 9.
# rez = t2-t
# p rez
