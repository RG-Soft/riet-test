
Функция ПолучитьПоКоду(Код) Экспорт
	
	// Возвращат ссылку, ищет по коду
	// В отличие от стандартной функции - отсекает помеченные не удаление
	// Рекомендуется вызывать из модуля с повторным использованием значений
	
	Возврат РГСофт.НайтиСсылку("Справочник", "Incoterms", "Код", Код);
	
КонецФункции