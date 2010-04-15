class FieldInfo
  attr_accessor :field, :subfield, :coll, :row, :q
  def field_without_first
    field.split(".")[1..-1]
  end
  def first_field
    field.split(".").first
  end
  def fields_without_numbers
    field.split(".").reject { |x| x.num? }.join(".")
  end
  include FromHash
  fattr(:raw_top_field_value) do 
    row[first_field] 
  end
  fattr(:top_field_value) do
    # if raw_top_field_value.present?
    #       raw_top_field_value
    #     else
    #       [all_hash_keys.to_empty_hash]
    #     end
    raw_top_field_value
  end
  fattr(:field_value) do
    res = field_without_first.empty? ? top_field_value : top_field_value.dot_get(field_without_first)
    #res = all_hash_keys.to_empty_hash if res == :badi
    res
  end
  def new_field_with_array_hash?
    field_value.blank? && all_hash_keys.size > 0
  end
  fattr(:field_class_str) do
    res = field_value.class.to_s
    res = 'Hash' if res == 'OrderedHash'
    # res = 'Array' if new_field_with_array_hash?
    res
  end
  fattr(:existing_value_all_hash_keys) do
    if raw_top_field_value.kind_of?(Array) && raw_top_field_value.contains_all_hashes?
      raw_top_field_value.map { |x| x.coll_keys }.flatten.uniq.sort
    else
      nil
    end
  end
  fattr(:new_value_all_hash_keys) do
    log 'class', coll.class
    coll.all_hash_keys(first_field)
  end
  fattr(:all_hash_keys) do
    # raw_top_field_value.present? ? existing_value_all_hash_keys : new_value_all_hash_keys
    new_value_all_hash_keys
    # ['amount','odds']
  end
  fattr(:json_field_value) do
    field_value
  end
  fattr(:json_str) do
    res = {'field_type' => field_class_str, 'value' => json_field_value, 'array_hash_keys' => all_hash_keys}
    res.to_json.tap { |x| log :field_info, x }
  end
  def possible_values
    rows = coll.find(fields_without_numbers => /#{q}/i)
    field.split(".").each do |f|
      log :field_info, :rows => rows, :f => f
      if f.num?
        temp = []
        rows.each { |x| temp += x }
        rows = temp
      else
        rows = rows.map { |x| x[f] }
      end
    end
    #rows.map { |x| x['line'].map { |x| x['site'] } }.flatten.uniq.sort.select { |x| x =~ /^#{q}/i }
    log :field_info, rows.inspect
    rows.select { |x| x =~ /#{q}/i }.uniq.sort
  end
end