
Функция ПолучитьПоКоду(Код) Экспорт
	
	// Получает Customs card по коду
	// В отличие от стандартной функции отсекаются помеченные на удаление элементы
	// Рекомендуется вызывать из модуля с повторным использованием значений
	
	Возврат РГСофт.НайтиСсылку("Справочник", "CustomsCards", "Код", Код);
	
КонецФункции