class FieldInfo
  attr_accessor :field, :subfield, :coll, :row
  include FromHash
  fattr(:raw_top_field_value) do 
    row[field] 
  end
  fattr(:top_field_value) do
    if raw_top_field_value.present?
      raw_top_field_value
    else
      [all_hash_keys.to_empty_hash]
    end
  end
  fattr(:casted_subfield) { top_field_value.kind_of?(Array) ? subfield.safe_to_i : subfield }
  fattr(:field_value) do
    if subfield.present?
      top_field_value[casted_subfield]
    else
      top_field_value
    end
  end
  def new_field_with_array_hash?
    subfield.blank? && field_value.blank? && all_hash_keys.size > 0
  end
  fattr(:field_class_str) do
    res = field_value.class.to_s
    res = 'Hash' if res == 'OrderedHash'
    res = 'Array' if new_field_with_array_hash?
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
    coll.all_hash_keys(field)
  end
  fattr(:all_hash_keys) do
    raw_top_field_value.present? ? existing_value_all_hash_keys : new_value_all_hash_keys
  end
  fattr(:json_field_value) do
    #new_field_with_array_hash? ? [all_hash_keys.to_empty_hash] : field_value
    #new_field_with_array_hash? ? [] : field_value
    field_value
  end
  fattr(:json_str) do
    res = {'field_type' => field_class_str, 'value' => json_field_value, 'array_hash_keys' => all_hash_keys}
    res.to_json.tap { |x| log :field_info, x }
  end
end