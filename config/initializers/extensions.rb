#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class Hash
  def rewrite(mapping)
    inject({}) do |rewritten_hash, (original_key, value)|
      rewritten_hash[mapping.fetch(original_key, original_key)] = value
      rewritten_hash
    end
  end

  # Create a hash from an array of keys and corresponding values.
  def self.zip(keys, values)
    hash[*keys] = values
    hash
  end
end

class Array
  def swap!(a,b)
       self[a], self[b] = self[b], self[a]
    self
  end

  def pick_at_random
		self.sample
	end
end

class String

  def valid_integer?
    # The double negation turns this into an actual boolean true - if you're
    # okay with "truthy" values (like 0.0), you can remove it.
    !!Integer(self) rescue false
  end

  def valid_float?
    # The double negation turns this into an actual boolean true - if you're
    # okay with "truthy" values (like 0.0), you can remove it.
    !!Float(self) rescue false
  end

  def is_numeric?
    self.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  #Tranform some special characters in a simple characters. (é => e or à => a)
  def self.keep_clean_space(str)
    accents = { ['á','à','â','ä','ã','Ã','Ä','Â','À'] => 'a',
      ['é','è','ê','ë','Ë','É','È','Ê'] => 'e',
      ['í','ì','î','ï','I','Î','Ì'] => 'i',
      ['ó','ò','ô','ö','õ','Õ','Ö','Ô','Ò'] => 'o',
      ['ç'] => 'c',
      ['œ'] => 'oe',
      ['ß'] => 'ss',
      ['ú','ù','û','ü','U','Û','Ù'] => 'u',
      ['-', '\'', '&', '~', '{', '[', '^', '@', ' '] => '_'
    }

    st = String.new(str)
    accents.each { |ac,rep| ac.each  { |s| st.gsub!(s, rep) } }
    st.downcase
  end

  def self.to_index_url(str)
    String::keep_clean_space(str).pluralize
  end
end

class Standards
	def self.random_string(len)
		(1..len).collect { Standards.alphanumeric_characters.pick_at_random }.join
	end

	def self.alphanumeric_characters
		("A".."Z").to_a + ("a".."z").to_a + ("0".."9").to_a
	end
end

class CustomCSV < CSV
  def gets(*args)
    line = super
    if line != nil
      line.gsub!('\\"','""')  # fix the \" that would otherwise cause a parse error
    end
    line
  end
end

class Integer
  def plusplus
    self + 1
  end
end