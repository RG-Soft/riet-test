Перем мПериод          Экспорт; // Период движений
Перем мТаблицаДвижений Экспорт; // Таблица движений

Процедура ДобавитьДвижение(ЗаполнитьДатуСобытия = истина) Экспорт
	
	//мТаблицаДвижений.ЗаполнитьЗначения( мПериод, "Период");
	мТаблицаДвижений.ЗаполнитьЗначения( Истина,  "Активность");
	
	Если мТаблицаДвижений.Колонки.Найти("ДатаСобытия") = Неопределено Тогда
		мТаблицаДвижений.Колонки.Добавить("ДатаСобытия");
		ЗаполнитьДатуСобытия = истина;
	КонецЕсли; 
	
	Если ЗаполнитьДатуСобытия Тогда
		мТаблицаДвижений.ЗаполнитьЗначения( мПериод, "ДатаСобытия");
	КонецЕсли; 
	
	ОбщегоНазначения.ВыполнитьДвижениеПоРегистру(ЭтотОбъект);
	
КонецПроцедуры // ДобавитьДвижение()

// Процедура - обработчик события перед записью в регистр
//
Процедура ПередЗаписью(Отказ, Замещение)
			
	SalesBook.ЗаполнитьПодразделениеИИнвойсинговыйЦентр(ЭтотОбъект);
	
КонецПроцедуры
