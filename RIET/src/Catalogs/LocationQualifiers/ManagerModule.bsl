
Функция ПолучитьПоКоду(Код) Экспорт
	
	// Возвращает ссылку, ищет по Коду
	// Отсекает помеченные на удаление, если найдено несколько возвращает Неопределено
	// Рекомендуется вызывать из модуля с повторным использованием значений
	
	Возврат РГСофт.НайтиСсылку("Справочник", "LocationQualifiers", "Код", Код);
	
КонецФункции