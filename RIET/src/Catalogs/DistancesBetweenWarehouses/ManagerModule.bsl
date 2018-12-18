
Функция ПроверимМаршрут(Source, Destination, MOT) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	DistancesBetweenWarehouses.Ссылка
	|ИЗ
	|	Справочник.DistancesBetweenWarehouses КАК DistancesBetweenWarehouses
	|ГДЕ
	|	DistancesBetweenWarehouses.SourceLocation = &SourceLocation
	|	И DistancesBetweenWarehouses.DestinationLocation = &DestinationLocation
	|	И DistancesBetweenWarehouses.MOT = &MOT";
	Запрос.УстановитьПараметр("SourceLocation", Source);
	Запрос.УстановитьПараметр("DestinationLocation", Destination);
	Запрос.УстановитьПараметр("MOT", MOT);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
КонецФункции