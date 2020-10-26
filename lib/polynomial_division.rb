module Silicium


  module Algebra
    ##
    # TODO: class docs
    class PolynomialDivision
      # This function returns an array of coefficients obtained by parsing input string in format: "<coeff>*x**<degree>+..."
      # Even if in your expression don't exist x with some degree, you should to write it with 0 coefficient
      # Also free term you should to write with 0 degree
      # Example: "2*x**5-3*x**4+0*x**3+0*x**2-5*x**1-6*x**0"
      def polynom_parser(str)
        copy_str = str.clone
        sgn_array = []                    # Array of signs
        if copy_str[0] != '-'
          sgn_array.push('+')
        else
          sgn_array.push('-')
          copy_str[0] = ''
        end
        token = copy_str.split(/[-+]/)
        (0..copy_str.size-1).each do |i|
          if copy_str[i] == '-' || copy_str[i] == '+'
            sgn_array.push(copy_str[i])
          end
        end
        size = token.size - 1
        coeff = Array.new                 # Array of coefficients
        (0..size).each do |i|
          degree = token[i].split('*')    # Split by '*' to get coefficient and degree
          degree[0] == 'x' ? coeff[i] = 1.0 : coeff[i] = degree[0].to_f
          if sgn_array[i] == '-'
            coeff[i] *= -1
          end
        end
        coeff
      end

# String implementation of result
      def str_res_impl(coeff_res, sgn_array)
        res_size = coeff_res.size
        res_exp = ""
        (0..res_size-1).each do |i|
          res_exp += ((coeff_res[i].ceil(3)).to_s+"*x**"+(res_size - i - 1).to_s)
          if sgn_array[i+1] != '-'
            res_exp += sgn_array[i+1]
          end
        end
        res_exp
      end

# String implementation of remained part
      def str_rem_impl(coeff_1)
        c = coeff_1.size
        rem_exp = ""
        (0..c-1).each do |i|
          if coeff_1[i] >= 0.0
            rem_exp += '+'
          end
          rem_exp += ((coeff_1[i].ceil(3)).to_s+"*x**"+(c - i - 1).to_s)
        end
        if rem_exp[0] == '+'
          rem_exp[0] = ''
        end
        rem_exp
      end

# This function returns array of 2 strings: first is the result of division polynom poly_1 on polynom poly_2
# Second - remainder
      def polynom_division(poly_1, poly_2)
        coeff_1 = polynom_parser(poly_1)
        coeff_2 = polynom_parser(poly_2)
        res_size = coeff_1.size - coeff_2.size + 1
        coeff_result = Array.new(res_size)
        sgn_array = Array.new(res_size + 1,'')
        (0..res_size-1).each do |i|
          cur_coeff = coeff_1[i] / coeff_2[0]
          coeff_result[i] = cur_coeff
          coeff_result[i] < 0 ? sgn_array[i] = '-' : sgn_array[i] = '+'
          (0..coeff_2.size-1).each do |j|
            coeff_1[i+j] -= coeff_2[j]*cur_coeff
          end
        end
        res_exp = str_res_impl(coeff_result, sgn_array)
        rem_exp = str_rem_impl(coeff_1[coeff_result.size..coeff_1.size-1])
        [res_exp, rem_exp]
      end

      # This function returns a string: greatest common integer divisor of two polynoms
      def polynom_gcd(poly_1, poly_2)
        coeff_array_1 = polynom_parser(poly_1)
        coeff_array_2 = polynom_parser(poly_2)

        #"Bigger" polynom should be divided by "smaller" polynom, compare by degree
        if coeff_array_1.size >= coeff_array_2.size
          dividend = poly_1
          divisor = poly_2
        else
          dividend = poly_2
          divisor = poly_1
        end

        division = polynom_division(dividend, divisor)
        remainder = division[1]

        #Providing precision because of storage of float numbers
        until polynom_parser(remainder).all?{|item| item.abs < 0.01} do
          division = polynom_division(divisor, remainder)
          new_remainder = division[1]
          divisor = remainder
          remainder = new_remainder
        end

        # Division of greatest common divisor by number does not change the sense of greatest common divisor
        # So I do this to make the first coefficient of resulting polynom be 1
        normalizer = polynom_parser(divisor)[0]
        temp_result = polynom_division(divisor, normalizer.to_s+"*x**0")[0]

        #There still can be an error, so I round coefficients which are really needed in it(condition in map! method)
        coeffs = polynom_parser(temp_result)
        coeffs.map! { |element| (element.round - element).abs < 0.01 ? element.round.to_f : element}

        # And then create a new string with valid coefficients - The True Greatest Common Divisor
        gcd = ""
        size = coeffs.size
        for index in 0..(size - 1) do
          coeff = coeffs[index]
          plus = (coeff >= 0 and index != 0) ? "+" : ""
          gcd += "#{plus}#{coeff}*x**#{size - index - 1}"
        end
        gcd
      end
    end
  end
end
