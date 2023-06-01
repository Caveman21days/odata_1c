## Получение документации

    yard server
    
## Базовое использование

### Пример получения всех ФИО в списке физических лиц 1С

```ruby
begin
    # Соединиться с 1С
    connection = Odata1c.connect host: 'localhost', db_name: '1c_db', user: '1c_user'

    # Получить сущность "Catalog_ФизическиеЛица"
    entity = connection['Catalog_ФизическиеЛица'] # => Entity
    
    # Запросить список всех значений "Catalog_ФизическиеЛица"
    people = entity.list  #=> Array<EntityValues>
    
    # Получить значения свойства "ФИО"
    people.map{|person| person['ФИО']} # => Array<String>
rescue Odata1c::Error => error
  puts "Ошибка при взаимодействии с 1С: #{error}"
end
```
