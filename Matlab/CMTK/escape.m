function e = escape(str)
%escape returns the string sourrounded by '
%(useful when a file name contrain spaces for example)
e = join(["" str ""], "'");
end