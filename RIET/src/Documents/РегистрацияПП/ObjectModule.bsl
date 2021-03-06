
Перем мВалютаРегламентированногоУчета Экспорт;

//Добавил РГ-Софт - Пронин Иван
Перем мУдалятьДвижения;
//Конец добавления


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

Процедура ПодготовитьТаблицуПоСчетам(СтруктураШапкиДокумента, ТаблицаПоСчетам, Отказ, Заголовок)
	
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("НомерВаучера"			, "НомерВаучера");
	СтруктураПолей.Вставить("НомерСчета"			, "НомерСчета");
	СтруктураПолей.Вставить("ДатаСчета"				, "ДатаСчета");
	
	СтруктураПолей.Вставить("СуммаОплатыСНДС"		, "СуммаОплатыСНДС");
	СтруктураПолей.Вставить("ВалютаОплаты"			, "ВалютаОплаты");
	СтруктураПолей.Вставить("СтавкаНДС"				, "СтавкаНДС");
	
	СтруктураПолей.Вставить("СуммаОплатыСНДСРуб"	, "СуммаОплатыСНДСРуб");
	СтруктураПолей.Вставить("СуммаОплатыБезНДСРуб"	, "СуммаОплатыБезНДСРуб");
	СтруктураПолей.Вставить("СуммаНДСОплатыРуб"		, "СуммаНДСОплатыРуб");
			
	СтруктураПолей.Вставить("Предоплата"			, "Предоплата");
	СтруктураПолей.Вставить("ШвепсПО"				, "ШвепсПО");
	
	РезультатЗапросаПоСчетам = УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "Счета", СтруктураПолей);
	ТаблицаПоСчетам = РезультатЗапросаПоСчетам.Выгрузить();
	
КонецПроцедуры

Процедура ПодготовитьТаблицуПоСФ(СтруктураШапкиДокумента, ТаблицаПоСФ, Отказ, Заголовок)
		
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("СФСсылка",				"СФСсылка");
	СтруктураПолей.Вставить("НомерСчета",			"СФСсылка.НомерСчета");
	СтруктураПолей.Вставить("СтавкаНДС",		    "СФСсылка.СтавкаНДССФ");
	
	СтруктураПолей.Вставить("СуммаБезНДССФ",		"СФСсылка.СуммаСФБезНДСРуб");
	СтруктураПолей.Вставить("СуммаНДССФ",			"СФСсылка.СуммаНДССФРуб");
	
	СтруктураПолей.Вставить("НомерСФ",				"СФСсылка.НомерВходящейСФ");
	СтруктураПолей.Вставить("ДатаСФ",				"СФСсылка.ДатаВходящейСФ");
	СтруктураПолей.Вставить("ВалютаСФ",				"СФСсылка.ВалютаСФ");
	// ЗАПОЛНЕНИЕ ЭТИХ ПОЛЕЙ В СФ АКТ УПР НЕ ПРОВЕРЯЕТСЯ!!!
	// ПРАВИЛЬНО, ЧТО LAWSON, А НЕ 1С???
	СтруктураПолей.Вставить("БухСчет",				"СФСсылка.БухСчетLawson");
	СтруктураПолей.Вставить("AU",					"СФСсылка.AULawson");
	СтруктураПолей.Вставить("Подразделение",		"СФСсылка.ПодразделениеОрганизации");		
	
	// Для движений по ОборудованиеЛокальное
	СтруктураПолей.Вставить("НомерПрихода",			"СФСсылка.НомерПрихода");
	СтруктураПолей.Вставить("ДатаПрихода",			"СФСсылка.ДатаПрихода");	
    СтруктураПолей.Вставить("AU1C",					"СФСсылка.AU1C");
	СтруктураПолей.Вставить("ОписаниеЗатрат",		"СФСсылка.ОписаниеЗатрат");
	
	// ОСТАЛОСЬ ОТ СТАРОГО ПРОВЕДЕНИЯ, КОГДА ДАННЫЕ СФ МОГЛИ ЗАПОЛНЯТЬСЯ ПРЯМО В РЕГИСТРАЦИИ ПП
	//СтруктураПолей.Вставить("СуммаСФ",			"СуммаСФ");
	//СтруктураПолей.Вставить("СуммаСФРуб",			"СуммаСФРуб");
	//
	//СтруктураПолей.Вставить("ДатаРегистрацииСФ",	"ДатаРегистрацииСФ");
	//
	//СтруктураПолей.Вставить("ДатаРегистрацииПрихода",	"ДатаРегистрацииПрихода");
	//СтруктураПолей.Вставить("СуммаПрихода",		"СуммаПрихода");
	//СтруктураПолей.Вставить("ВалютаПрихода",		"ВалютаПрихода");
	//СтруктураПолей.Вставить("СуммаПриходаРуб",	"СуммаПриходаРуб");	
		
	//СтруктураПолей.Вставить("БухСчет1С",			"БухСчет1С");	
	//СтруктураПолей.Вставить("Проверено",			"Проверено");	
	
	//СтруктураПолей.Вставить("Причина",			"Причина");
		
	РезультатЗапросаПоСФ = УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "СчетаФактуры", СтруктураПолей);
	ТаблицаПоСФ = РезультатЗапросаПоСФ.Выгрузить();
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура;
	СтруктураОбязательныхПолей.Вставить("ДатаПроведения");
	СтруктураОбязательныхПолей.Вставить("НалоговыйПериод");
	// НОМЕР ОРГАНИЗАЦИИ НАДО ПИСАТЬ В ИНФОРМАЦИОННЫЙ РЕКВИЗИТ!!!
	СтруктураОбязательныхПолей.Вставить("Организация");
	СтруктураОбязательныхПолей.Вставить("НомерПП");
	//СтруктураОбязательныхПолей.Вставить("ДатаПП");
	СтруктураОбязательныхПолей.Вставить("Контрагент");
	СтруктураОбязательныхПолей.Вставить("Валюта");
	
	// Теперь позовем общую процедуру проверки.
	ОбщегоНазначения.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок, Ложь, Истина);
	
	// Может быть и стоит проверять, но регистрировать точно пока не стоит, так как документ пока не используется.
	//Если Не ЗначениеЗаполнено(СокрЛП(СтруктураШапкиДокумента.НомерПП)) Тогда
	//	УчетОшибокЗаполнения.ЗарегистрироватьОшибкуВШапкеТипаНеЗаполнен(ЭтотОбъект, "НомерПП", , Отказ, Истина, Заголовок);
	//КонецЕсли;
		
КонецПроцедуры // ПроверитьЗаполнениеШапки()

Процедура ПроверитьЗаполнениеТабличныхЧастей(СтруктураШапкиДокумента, ТаблицаПоСчетам, ТаблицаПоСФ, Отказ, Заголовок)
	
	// СЧЕТА
    
	СтруктураОбязательныхПолей = Новый Структура;
	СтруктураОбязательныхПолей.Вставить("НомерВаучера");
	СтруктураОбязательныхПолей.Вставить("НомерСчета");
	СтруктураОбязательныхПолей.Вставить("ДатаСчета");
	СтруктураОбязательныхПолей.Вставить("СуммаОплатыСНДС");
	СтруктураОбязательныхПолей.Вставить("ВалютаОплаты");
	СтруктураОбязательныхПолей.Вставить("СтавкаНДС");
	СтруктураОбязательныхПолей.Вставить("СуммаОплатыСНДСРуб");	
	СтруктураОбязательныхПолей.Вставить("СуммаОплатыБезНДСРуб");
	СтруктураОбязательныхПолей.Вставить("ШвепсПО");
	ОбщегоНазначения.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Счета", СтруктураОбязательныхПолей, Отказ, Заголовок, , Ложь, Истина);

	// Выполним более сложные проверки
	Для Каждого СтрокаТаблицыПоСчетам Из ТаблицаПоСчетам Цикл
		
		// Может быть проверять и стоит, но регистрировать точно не стоит, так как документ не используется
	//	// Номер ваучера
	//	Если СокрЛП(СтрокаТаблицыПоСчетам.НомерВаучера) = "" Тогда
	//		УчетОшибокЗаполнения.ЗарегистрироватьОшибкуВТЧТипаНеЗаполнен(ЭтотОбъект, "Счета", СтрокаТаблицыПоСчетам.НомерСтроки, "НомерВаучера", , Отказ, Истина, Заголовок);
	//	КонецЕсли;
	//	
	//	// Номер счета
	//	Если СокрЛП(СтрокаТаблицыПоСчетам.НомерСчета) = "" Тогда
	//		УчетОшибокЗаполнения.ЗарегистрироватьОшибкуВТЧТипаНеЗаполнен(ЭтотОбъект, "Счета", СтрокаТаблицыПоСчетам.НомерСтроки, "НомерСчета", , Отказ, Истина, Заголовок);
	//	КонецЕсли;
	//
	//	// Сумма НДС Счета
	//	Если НЕ ОбщегоНазначения.ЗначениеСуммаНДСЗаполнено(СтрокаТаблицыПоСчетам.СтавкаНДС, СтрокаТаблицыПоСчетам.СуммаНДСОплатыРуб) Тогда
	//		УчетОшибокЗаполнения.ЗарегистрироватьОшибкуВТЧТипаНеЗаполнен(ЭтотОбъект, "Счета", СтрокаТаблицыПоСчетам.НомерСтроки, "СуммаНДСОплатыРуб", , Отказ, Истина, Заголовок);
	//	КонецЕсли;
		
	КонецЦикла;
	
	
	
	// СЧЕТА-ФАКТУРЫ
	
	//СтруктураОбязательныхПолей = Новый Структура;
	//СтруктураОбязательныхПолей.Вставить("СФСсылка");
	// ОСТАЛЬНЫЕ ПОЛЯ ПО ИДЕЕ ЗАПОЛНЯТЬ НЕ ОБЯЗАТЕЛЬНО! ВСЕ ЕСТЬ В СФ!
	//СтруктураОбязательныхПолей.Вставить("ДатаСФ");
	//СтруктураОбязательныхПолей.Вставить("СуммаСФ");
	//СтруктураОбязательныхПолей.Вставить("ВалютаСФ");
	//СтруктураОбязательныхПолей.Вставить("СуммаСФРуб");
	//СтруктураОбязательныхПолей.Вставить("СтавкаНДС");
	//СтруктураОбязательныхПолей.Вставить("СуммаБезНДССФ");	
	
	//СтруктураОбязательныхПолей.Вставить("НомерПрихода");
	//СтруктураОбязательныхПолей.Вставить("ДатаПрихода");
	//СтруктураОбязательныхПолей.Вставить("ВалютаПрихода");
	//СтруктураОбязательныхПолей.Вставить("AU1C");
	//СтруктураОбязательныхПолей.Вставить("БухСчет1С");
	//СтруктураОбязательныхПолей.Вставить("ОписаниеЗатрат");
	
	//ОбщегоНазначения.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "СчетаФактуры", СтруктураОбязательныхПолей, Отказ, Заголовок, , Ложь, Истина);
	
	// Выполним более сложные проверки
	Для Каждого СтрокаСФ Из ТаблицаПоСФ Цикл
		
		// Может быть проверять и стоит, но регистрировать точно не стоит, так как документ не используется
		//// Проверка проведенности документа Счет-факрутра
		//Если ЗначениеЗаполнено(СтрокаСФ.СФСсылка)
		//	И НЕ СтрокаСФ.СФСсылка.Проведен Тогда
		//	
		//	ТекстОшибки = "Указана непроведенная счет-фактура!";
		//	УчетОшибокЗаполнения.ЗарегистрироватьОшибкуВТЧТипаЗаполненНеправильно(ЭтотОбъект, "Счета-фактуры", СтрокаСФ.НомерСтроки, "Счет-фактура", ТекстОшибки, , Отказ, Истина, Заголовок);
		//	
		//КонецЕсли;
		//
		//// Одной СФ должна соответствовать только одна строчка из ТЗ Счета
		//СтруктураПоиска = Новый Структура("НомерСчета, СтавкаНДС", СтрокаСФ.НомерСчета, СтрокаСФ.СтавкаНДС); 	
		//НайденныеСтрокиТаблицыСчетов = ТаблицаПоСчетам.НайтиСтроки(СтруктураПоиска);
		//КоличествоНайденныхСтрок = НайденныеСтрокиТаблицыСчетов.Количество();
		//Если КоличествоНайденныхСтрок > 1 Тогда
		//	
		//	ТекстОшибки = "Для данной строки найдено несколько строк табличной части ""Счета"", соответствующие номеру счета и ставке НДС СФ!";
		//	УчетОшибокЗаполнения.ЗарегистрироватьОшибкуВТЧТипаЗаполненНеправильно(ЭтотОбъект, "Счета-фактуры", СтрокаСФ.НомерСтроки, "Счет-фактура", ТекстОшибки, , Отказ, Истина, Заголовок);
		//	
		//ИначеЕсли КоличествоНайденныхСтрок = 0 Тогда
		//	
		//	ТекстОшибки = "Для данной строки не найдено строк табличной части ""Счета"", соответствующих номеру счета и ставке НДС СФ!";
		//	УчетОшибокЗаполнения.ЗарегистрироватьОшибкуВТЧТипаЗаполненНеправильно(ЭтотОбъект, "Счета-фактуры", СтрокаСФ.НомерСтроки, "Счет-фактура", ТекстОшибки, , Отказ, Истина, Заголовок);
		//	
		//КонецЕсли;
		
		// ОСТАЛЬНЫЕ ПОЛЯ ПО ИДЕЕ ЗАПОЛНЯТЬ НЕ ОБЯЗАТЕЛЬНО! ВСЕ ЕСТЬ В СФ!
		//// Номер Счета
		//Если СокрЛП(СтрокаСФ.НомерСчета) = "" Тогда
		//	ТекстОшибки = "В строке номер " + СтрокаСФ.НомерСтроки + " табличной части ""Счета-фактуры"": Не заполнено значение реквизита ""Номер Счета""!";
		//	ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ, Заголовок);
		//КонецЕсли;
		//
		//// Номер CФ
		//Если СокрЛП(СтрокаСФ.НомерСФ) = "" Тогда
		//	ТекстОшибки = "В строке номер " + СтрокаСФ.НомерСтроки + " табличной части ""Счета-фактуры"": Не заполнено значение реквизита ""Номер СФ""!";
		//	ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ, Заголовок);
		//КонецЕсли;
		//			
		//// Номер прихода
		//Если СокрЛП(СтрокаСФ.НомерПрихода) = "" Тогда
		//	ТекстОшибки = "В строке номер " + СтрокаСФ.НомерСтроки + " табличной части ""Счета-фактуры"": Не заполнено значение реквизита ""Номер прихода""!";
		//	ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ, Заголовок);
		//КонецЕсли;

		//// Сумма НДС СФ
		//Если НЕ ОбщегоНазначения.ЗначениеСуммаНДСЗаполнено(СтрокаСФ.СтавкаНДС, СтрокаСФ.СуммаНДССФ) Тогда
		//	ТекстОшибки = "В строке номер " + СтрокаСФ.НомерСтроки + " табличной части ""Счета-фактуры"": Не заполнено значение реквизита ""Сумма НДС""!";
		//	ОбщегоНазначения.СообщитьОбОшибке(ТекстОшибки, Отказ, Заголовок);
		//КонецЕсли;
								
	КонецЦикла;

		
	// ДОДЕЛАТЬ ДОПОЛНИТЕЛЬНЫЕ ПРОВЕРКИ!!!
	
	// Может быть проверять и стоит, но регистрировать точно не стоит, так как документ не используется
	//// Проверим соответствие сумм
	//Если СтруктураШапкиДокумента.СуммаПлатежа <> ТаблицаПоСчетам.Итог("СуммаОплатыСНДСРуб")
	//	И Валюта = мВалютаРегламентированногоУчета Тогда
	//	
	//	// ОТКАЗ НЕ ПЕРЕДАЕТСЯ!!!
	//	ТекстОшибки = "Сумма платежа документа не совпадает с суммой счетов табличной части!";
	//	УчетОшибокЗаполнения.ЗарегистрироватьОшибкуВШапкеТипаЗаполненНеправильно(ЭтотОбъект, "Сумма платежа", ТекстОшибки, , Истина, Заголовок);
	//			
	//КонецЕсли;

	
	// Проверка отсутствия СЧA по предоплате
	//Запрос=Новый Запрос(
	//	"ВЫБРАТЬ
	//	|	РегистрацияППСчетаФактуры.НомерСФ,
	//	|	РегистрацияППСчетаФактуры.ДатаСф,
	//	|	РегистрацияППСчета.Предоплата,
	//	|	РегистрацияППСчетаФактуры.НомерСтроки
	//	|ИЗ
	//	|	Документ.РегистрацияПП.Счета КАК РегистрацияППСчета
	//	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РегистрацияПП.СчетаФактуры КАК РегистрацияППСчетаФактуры
	//	|		ПО РегистрацияППСчета.НомерСчета = РегистрацияППСчетаФактуры.НомерСчета
	//	|			И РегистрацияППСчета.СтавкаНДС = РегистрацияППСчетаФактуры.СтавкаНДС
	//	|			И РегистрацияППСчета.Ссылка = РегистрацияППСчетаФактуры.Ссылка
	//	|ГДЕ
	//	|	РегистрацияППСчета.Ссылка = &Ссылка
	//	|	И РегистрацияППСчетаФактуры.Ссылка = &Ссылка
	//	|	И РегистрацияППСчета.Предоплата = Истина");
	//Запрос.УстановитьПараметр("Ссылка", Ссылка);					
	//Выборка=Запрос.Выполнить().Выбрать();
	//Пока Выборка.Следующий() Цикл
	//	
	//	// ОТКАЗ НЕ ПЕРЕДАЕТСЯ!!!
	//	ОбщегоНазначения.СообщитьОбОшибке("В строке "+ Выборка.НомерСтроки + " указана счет-фактура к счету предоплаты!", , Заголовок);
	//	
	//КонецЦикла;	
	//
	//// Проверка того, что сумма СЧФ не больше суммы счета
	//Запрос=Новый Запрос(
	//	"ВЫБРАТЬ
	//	|	РегистрацияППСчетаФактуры.НомерСФ,
	//	|	РегистрацияППСчетаФактуры.ДатаСф,
	//	|	РегистрацияППСчета.Предоплата,
	//	|	РегистрацияППСчетаФактуры.НомерСтроки,
	//	|	РегистрацияППСчета.СуммаОплатыСНДСРуб,
	//	|	РегистрацияППСчетаФактуры.СуммаСФРуб
	//	|ИЗ
	//	|	Документ.РегистрацияПП.Счета КАК РегистрацияППСчета
	//	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РегистрацияПП.СчетаФактуры КАК РегистрацияППСчетаФактуры
	//	|		ПО РегистрацияППСчета.СтавкаНДС = РегистрацияППСчетаФактуры.СтавкаНДС
	//	|			И РегистрацияППСчета.Ссылка = РегистрацияППСчетаФактуры.Ссылка
	//	|			И РегистрацияППСчета.НомерСчета = РегистрацияППСчетаФактуры.НомерСчета
	//	|ГДЕ
	//	|	РегистрацияППСчета.Ссылка = &Ссылка
	//	|	И РегистрацияППСчетаФактуры.Ссылка = &Ссылка");
	//Запрос.УстановитьПараметр("Ссылка", Ссылка);					
	//Выборка=Запрос.Выполнить().Выбрать();
	//Пока Выборка.Следующий() Цикл
	//	Если Выборка.СуммаОплатыСНДСРуб - Выборка.СуммаСФРуб < 0 тогда
	//		
	//		// ОТКАЗ НЕ ПЕРЕДАЕТСЯ!!!
	//		ОбщегоНазначения.СообщитьОбОшибке("В строке " + Выборка.НомерСтроки + " указанная сумма счет-фактуры больше суммы счета!", , Заголовок);
	//		
	//	КонецЕсли;
	//КонецЦикла;
	
КонецПроцедуры

Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоСчетам, ТаблицаПоСФ, Отказ, Заголовок)
	
	ТЗСчета = ТаблицаПоСчетам.Скопировать();
	// ПОЧЕМУ СВОРАЧИВАЕТСЯ ПО ЭТИМ ПОЛЯМ? ПОЧЕМУ НЕ СВОРАЧИВАЕТСЯ ПО ВАЛЮТЕ СЧЕТА, ДАТЕ СЧЕТА, ПРЕДОПЛАТА, СУММЕ СЧЕТА, СУММЕ СЧЕТА ВАЛ, СУММА НДСВАЛ? 
	// ПОТОМ ИСПОЛЬЗУЮТСЯ ТОЛЬКО СУММАБЕЗНДСЧЕТА, СУММА НДССЧЕТА и ШВЕПСПО
	ТЗСчета.Свернуть("НомерСчета, НомерВаучера, СтавкаНДС, ШвепсПО", "СуммаОплатыСНДСРуб, СуммаОплатыБезНДСРуб, СуммаНДСОплатыРуб, СуммаОплатыСНДС");
	
	ТЗСЧФ = ТаблицаПоСФ.Скопировать();
	ТЗСЧФ.Свернуть("СФСсылка, НомерСчета, ВалютаСФ, СтавкаНДС, Подразделение, БухСчет", "СуммаБезНДССФ, СуммаНДССФ");
	
	// Цикл по ТЗ Счета-фактуры 
	Для Каждого СтрокаСФ Из ТаблицаПоСФ Цикл
		
		// Поиск соответствующих строк из ТЗ Счета
		СтруктураПоиска = Новый Структура("НомерСчета, СтавкаНДС", СтрокаСФ.НомерСчета, СтрокаСФ.СтавкаНДС); 	
		СтрСчета = ТЗСчета.НайтиСтроки(СтруктураПоиска);
		Оплата = СтрСчета[0];
		ТекВаучер = Оплата.НомерВаучера;
		
		// По НДСПокупкиУпр - НДС оплачен		
		СписатьБезНДСРуб	= Мин(СтрокаСФ.СуммаБезНДССФ	, Оплата.СуммаОплатыБезНДСРуб);
		СписатьНДСРуб		= Мин(СтрокаСФ.СуммаНДССФ		, Оплата.СуммаНДСОплатыРуб);
		// А ЭТА ПРОВЕРКА ЕЩЕ НУЖНА???
		Если СписатьБезНДСРуб > 0 ИЛИ СписатьНДСРуб > 0 Тогда
			
			Движение 					= Движения.НДСПокупкиУпр.Добавить();
			Движение.Событие 			= Перечисления.СобытияПоНДСПокупки.НДСОплачен;
			Движение.Организация 		= СтруктураШапкиДокумента.Организация;
			Движение.Период 			= СтруктураШапкиДокумента.ДатаПроведения; //Было СтруктураШапкиДокумента.ДатаПП;
			Движение.НомерСчета 		= СтрокаСФ.НомерСчета;
			Движение.НомерСФ 			= СтрокаСФ.НомерСФ;
			Движение.ДатаСФ 			= СтрокаСФ.ДатаСФ;
			Движение.Поставщик 			= СтруктураШапкиДокумента.Контрагент;
			Движение.Валюта 			= СтрокаСФ.ВалютаСФ;
			Движение.СтавкаНДС			= СтрокаСФ.СтавкаНДС;
			Движение.Подразделение		= СтрокаСФ.Подразделение;
			Движение.БухСчет			= СтрокаСФ.БухСчет;
			Движение.AU					= СтрокаСФ.AU;
			Движение.CashCode			= СтруктураШапкиДокумента.CashCode;
			Движение.НомерВаучера		= ТекВаучер;
			Движение.НалоговыйПериод	= СтруктураШапкиДокумента.НалоговыйПериод;
			Движение.СуммаБезНДС    	= СписатьБезНДСРуб;
			Движение.НДС   				= СписатьНДСРуб;

		КонецЕсли;
		
		// Движения, необходимые, когда СФ не заполнена
		// ТЕПЕРЬ СФ ДОЛЖНА БЫТЬ ЗАПОЛНЕНА ВСЕГДА!!!
		Если НЕ ЗначениеЗаполнено(СтрокаСФ.СФСсылка) Тогда
			
			//// Движение по НДСПокупкиУпр - Получен счет-фактура
			//Движение = Движения.НДСПокупкиУпр.Добавить();
			//Движение.Событие 			= Перечисления.СобытияПоНДСПокупки.ПолученСчетФактура;
			//Движение.Организация 		= СтруктураШапкиДокумента.Организация;
			//Движение.Период 			= СтруктураШапкиДокумента.ДатаПроведения; //Было СтрокаСФ.ДатаРегистрацииСФ;
			//Движение.НомерСчета 		= СтрокаСФ.НомерСчета;
			//Движение.НомерСФ 			= СтрокаСФ.НомерСФ;
			//Движение.ДатаСФ 			= СтрокаСФ.ДатаСФ;
			//Движение.Поставщик 		= СтруктураШапкиДокумента.Контрагент;
			//Движение.Валюта			= СтрокаСФ.ВалютаСФ;
			//Движение.СтавкаНДС		= СтрокаСФ.СтавкаНДС;
			//Движение.Подразделение	= СтрокаСФ.Подразделение;
			//Движение.БухСчет			= СтрокаСФ.БухСчет;
			//Движение.AU				= СтрокаСФ.AU;
			//Движение.CashCode			= СтруктураШапкиДокумента.CashCode;
			//Движение.НомерВаучера		= ТекВаучер;
			//Движение.БухСчет1С		= СтрокаСФ.БухСчет1С;
			//Движение.Проверено		= СтрокаСФ.Проверено;
			//Движение.НалоговыйПериод	= СтруктураШапкиДокумента.НалоговыйПериод;
			//Движение.СуммаБезНДС    	= СтрокаСФ.СуммаБезНДССФ;
			//Движение.НДС   			= СтрокаСФ.СуммаНДССФ;
			//
			//// Движения по Счета фактуры контрагентов
			//Движение = Движения.СчетаФактурыКонтрагентов.Добавить();
			//Движение.Период			= СтруктураШапкиДокумента.ДатаПроведения; //Было СтрокаСФ.ДатаРегистрацииСФ;
			//Движение.ДатаРегистрации	= СтрокаСФ.ДатаРегистрацииСФ;		
			//Движение.Валюта			= СтрокаСФ.ВалютаСФ;
			//Движение.Контрагент		= СтруктураШапкиДокумента.Контрагент;
			//Движение.ДатаСФ			= СтрокаСФ.ДатаСФ;
			//Движение.НомерСФ 			= СтрокаСФ.НомерСФ;
			//Движение.НомерСчета		= СтрокаСФ.НомерСчета;
			//Движение.НомерВаучера		= ТекВаучер;
			//Движение.СтавкаНДС		= СтрокаСФ.СтавкаНДС;
			//Движение.БухСчет1С		= СтрокаСФ.БухСчет1С;
			//Движение.AU1С				= СтрокаСФ.AU1C;
			//Движение.Причина			= СтрокаСФ.Причина;
			//Движение.ОписаниеЗатрат	= СтрокаСФ.ОписаниеЗатрат;
			//Движение.Сумма			= СтрокаСФ.СуммаСФ;
			//Движение.СуммаРуб			= СтрокаСФ.СуммаСФРуб;
			//
			//// Движения по Взаиморасчеты с поставщиками
			//Движение = Движения.ВзаиморасчетыСПоставщиками.Добавить();
			//Движение.ВидДвижения 		= ВидДвиженияНакопления.Расход;
			//Движение.Период 			= СтруктураШапкиДокумента.СтрокаСФ.ДатаСФ;
			//Движение.Контрагент 		= СтруктураШапкиДокумента.Контрагент;
			//Движение.Валюта 			= мВалютаРегламентированногоУчета;
			//Движение.CashCode 			= СтруктураШапкиДокумента.CashCode;
			//Движение.НомерСчета 		= СтрокаСФ.НомерСчета;
			//Движение.СтавкаНДС 			= СтрокаСФ.СтавкаНДС;
			//Движение.НомерДокумента 	= СтрокаСФ.НомерСФ;
			//Движение.Договор 			= СтруктураШапкиДокумента.Договор;
			//Движение.Сумма 				= СтрокаСФ.СуммаСФРуб;
			//Движение.СуммаНДС 			= СтрокаСФ.СуммаНДССФ;
			//
			//// Не заполнена счет фактура, но заполнена дата регистрации прихода
			//Если ЗначениеЗаполнено(СтрокаСФ.ДатаРегистрацииПрихода) Тогда
			//	
			//	// Движение по НДСПокупкиУпр - Предъявлен НДС поставщиком
			//	Движение = Движения.НДСПокупкиУпр.Добавить();
			//	Движение.Событие 			= Перечисления.СобытияПоНДСПокупки.ПредъявленНДСПоставщиком;
			//	Движение.Организация 		= СтруктураШапкиДокумента.Организация;
			//	Движение.Период 			= СтруктураШапкиДокумента.ДатаПроведения; //Было СтрокаСФ.ДатаРегистрацииПрихода;
			//	Движение.НомерСчета 		= СтрокаСФ.НомерСчета;
			//	Движение.НомерСФ 			= СтрокаСФ.НомерСФ;
			//	Движение.ДатаСФ 			= СтрокаСФ.ДатаСФ;
			//	Движение.Поставщик 			= СтруктураШапкиДокумента.Контрагент;
			//	Движение.Валюта 			= СтрокаСФ.ВалютаСФ;
			//	Движение.СтавкаНДС			= СтрокаСФ.СтавкаНДС;
			//	Движение.Подразделение		= СтрокаСФ.Подразделение;
			//	Движение.БухСчет			= СтрокаСФ.БухСчет1С;
			//	Движение.AU					= СтрокаСФ.AU1C;
			//	Движение.CashCode			= СтруктураШапкиДокумента.CashCode;
			//	Движение.НомерВаучера		= ТекВаучер;
			//	Движение.НалоговыйПериод	= СтруктураШапкиДокумента.НалоговыйПериод;
			//	Движение.СуммаБезНДС    	= СтрокаСФ.СуммаБезНДССФ;
			//	Движение.НДС   				= СтрокаСФ.СуммаНДССФ;

			//	
			//	// Движение по Акты контрагентов
			//	Движение = Движения.АктыКонтрагентов.Добавить();
			//	Движение.Период			= СтруктураШапкиДокумента.ДатаПроведения; //Было строкаСФ.ДатаРегистрацииПрихода;
			//	Движение.ДатаРегистрации= строкаСФ.ДатаРегистрацииПрихода;			
			//	Движение.Валюта			= строкаСФ.ВалютаПрихода;
			//	Движение.Контрагент		= СтруктураШапкиДокумента.Контрагент;
			//	Движение.ДатаПрихода	= строкаСФ.ДатаПрихода;
			//	Движение.НомерПрихода 	= строкаСФ.НомерПрихода;
			//	Движение.НомерСчета		= строкаСФ.НомерСчета;
			//	Движение.НомерВаучера	= ТекВаучер;
			//	Движение.СтавкаНДС		= строкаСФ.СтавкаНДС;
			//	Движение.Сумма			= строкаСФ.СуммаПрихода;
			//	Движение.СуммаРуб		= строкаСФ.СуммаПриходаРуб;
			//	
			//КонецЕсли; // Если Не ОбщегоНазначения.ЗначениеНеЗаполнено(СтрокаСФ.ДатаРегистрацииПрихода) 
			
		КонецЕсли; // Если НЕ ЗначениеЗаполнено(СтрокаСФ.СФСсылка) 
					
	КонецЦикла; //Для Каждого СтрокаСФ Из ТаблицаПоСФ Цикл	
	
	
	// Цикл по счетам
	Для Каждого СтрокаТаблицыПоСчетам из ТаблицаПоСчетам Цикл
		
		Если СтрокаТаблицыПоСчетам.Предоплата Тогда
			
			// Движение по НДС предоплаченные счета
			Движение=Движения.НДСПредоплаченныеСчета.Добавить();
			Движение.Период				= СтруктураШапкиДокумента.ДатаПроведения; //Было СтруктураШапкиДокумента.ДатаПП;
			Движение.ВидДвижения		= ВидДвиженияНакопления.Приход;
			// ЭТО ПРАВИЛЬНО???
			Движение.Валюта				= СтрокаТаблицыПоСчетам.ВалютаОплаты;
			Движение.Контрагент			= СтруктураШапкиДокумента.Контрагент;
			Движение.ДатаСчета			= СтрокаТаблицыПоСчетам.ДатаСчета;
			Движение.НомерСчета			= СтрокаТаблицыПоСчетам.НомерСчета;
			Движение.Сумма				= СтрокаТаблицыПоСчетам.СуммаОплатыСНДС;
			Движение.СуммаРуб			= СтрокаТаблицыПоСчетам.СуммаОплатыСНДСРуб;
			Движение.СтавкаНДС			= СтрокаТаблицыПоСчетам.СтавкаНДС;
			Движение.СуммаБезНДС		= СтрокаТаблицыПоСчетам.СуммаОплатыБезНДСРуб;
			Движение.СуммаНДС			= СтрокаТаблицыПоСчетам.СуммаНДСОплатыРуб;
			Движение.НалоговыйПериод	= СтруктураШапкиДокумента.НалоговыйПериод;
			
		Иначе // Если это не предоплата
			
			//Движение по курсовым разницам
			Если Не СтрокаТаблицыПоСчетам.ВалютаОплаты = мВалютаРегламентированногоУчета Тогда
				
				// Ищем счета-фактуры, соответствующие этому счету
				СтруктураПоискаСчетовФактур = Новый Структура("НомерСчета, СтавкаНДС", СтрокаТаблицыПоСчетам.НомерСчета, СтрокаТаблицыПоСчетам.СтавкаНДС);
				НужныеСчетаФактуры = ТЗСЧФ.НайтиСтроки(СтруктураПоискаСчетовФактур);
				ВременнаяТЗ = ТЗСЧФ.Скопировать(НужныеСчетаФактуры, "СуммаНДССФ");
				СуммаНДСРуб = ТЗСЧФ.Итог("СуммаНДССФ");
												
				Если СтрокаТаблицыПоСчетам.СуммаНДСОплатыРуб - СуммаНДСРуб <> 0 Тогда
					
					Движение = Движения.КурсовыеРазницы.Добавить();
					Движение.Период 			= СтруктураШапкиДокумента.ДатаПроведения;
					Движение.Контрагент			= СтруктураШапкиДокумента.Контрагент;
					Движение.ДатаСчета			= СтрокаТаблицыПоСчетам.ДатаСчета;
					Движение.НомерСчета			= СтрокаТаблицыПоСчетам.НомерСчета;
					// ЭТО ПРАВИЛЬНО???
					Движение.ВалютаСчета		= СтрокаТаблицыПоСчетам.ВалютаОплаты;
					Движение.НомерВаучера		= СтрокаТаблицыПоСчетам.НомерВаучера;
					Движение.CashCode			= СтруктураШапкиДокумента.CashCode;
					Движение.НалоговыйПериод	= СтруктураШапкиДокумента.НалоговыйПериод;
					Движение.КурсоваяРазница	= СтрокаТаблицыПоСчетам.СуммаНДСОплатыРуб - СуммаНДСРуб;
					
				КонецЕсли; //Если СтрокаТаблицыПоСчетам.СуммаНДСОплатыРуб - СуммаНДСРуб <> 0
				
			КонецЕсли; //Если Не СтрокаТаблицыПоСчетам.ВалютаОплаты = мВалютаРегламентированногоУчета
			
		КонецЕсли; //Если СтрокаТаблицыПоСчетам.Предоплата Тогда
		
		// По Счета контрагентов
		// Решили, что этот регистр пока не нужен
		//Движение = Движения.СчетаКонтрагентов.Добавить();
		//Движение.Период 			= СтруктураШапкиДокумента.ДатаПроведения;
		//Движение.ДатаРегистрации	= СтруктураШапкиДокумента.Дата;
		//Движение.Контрагент			= СтруктураШапкиДокумента.Контрагент;
		//Движение.ДатаСчета			= СтрокаТаблицыПоСчетам.ДатаСчета;
		//Движение.НомерСчета			= СтрокаТаблицыПоСчетам.НомерСчета;
		//// ПОДСТАВИТЬ ПРАВИЛЬНУЮ ВАЛЮТУ ИСХОДНОГО СЧЕТА
		//Движение.ВалютаСчета		= СтрокаТаблицыПоСчетам.АРХИВВалютаИсходногоСчета;
		//Движение.Валюта				= СтрокаТаблицыПоСчетам.ВалютаОплаты;
		//Движение.НомерВаучера		= СтрокаТаблицыПоСчетам.НомерВаучера;
		//Движение.НомерПП			= СтруктураШапкиДокумента.НомерПП;
		//Движение.ДатаПП				= СтруктураШапкиДокумента.ДатаПроведения; //Была ДатаПП
		//// ЧТО ЗДЕСЬ ПОДСТАВЛЯТЬ ВМЕСТО СУММАСЧЕТАВАЛ. ВЕДЬ ЭТОТ РЕКВИЗИТЫ ТЕПЕРЬ АРХИВНЫЙ!
		////Движение.СуммаСчетаВал		= СтрокаТаблицыПоСчетам.СуммаСчетаВал;
		//Движение.СуммаОплаты		= СтрокаТаблицыПоСчетам.СуммаОплатыСНДС;
		////ПОЧЕМУ СУММАСЧЕТА? А НЕ СУММАОПЛАТЫРУБ? РАЗОБРАТЬСЯ С НАИМЕНОВАНИЕМ РЕКВИЗИТОВ!!!
		//Движение.СуммаОплатыРуб		= СтрокаТаблицыПоСчетам.СуммаОплатыСНДСРуб;

		
		// Движение по Взаиморасчеты с поставщиками
		Движение = Движения.ВзаиморасчетыСПоставщиками.Добавить();
		Движение.ВидДвижения 	= ВидДвиженияНакопления.Приход;
		Движение.Период			= СтруктураШапкиДокумента.ДатаПроведения; //Было СтруктураШапкиДокумента.ДатаПП;
		Движение.Контрагент 	= СтруктураШапкиДокумента.Контрагент;
		Движение.НомерСчета 	= СтрокаТаблицыПоСчетам.НомерСчета;
		Движение.Валюта 		= мВалютаРегламентированногоУчета;
		Движение.CashCode 		= СтруктураШапкиДокумента.CashCode;
		Движение.СтавкаНДС 		= СтрокаТаблицыПоСчетам.СтавкаНДС;
		Движение.Сумма 			= СтрокаТаблицыПоСчетам.СуммаОплатыСНДСРуб;
		Движение.СуммаНДС 		= СтрокаТаблицыПоСчетам.СуммаНДСОплатыРуб;
		Движение.НомерДокумента	= СтруктураШапкиДокумента.НомерПП;

	КонецЦикла; // Для Каждого СтрокаТаблицыПоСчетам из ТаблицаПоСчетам Цикл
	
	
	// Движение по ОборудованиеЛокальное
	ТЗСЧФ = ТаблицаПоСФ.Скопировать();
	ТЗСЧФ.Свернуть("НомерСчета, СтавкаНДС, НомерПрихода, ДатаПрихода, AU1C, Подразделение, ОписаниеЗатрат", "СуммаБезНДССФ");
	
	//Цикл по ТЗ Счета-фактуры
	Для Каждого СтрокаТЗСЧФ из ТЗСЧФ Цикл
		
		// Ищем счета, соответствующие данной СФ
		СтруктураПоиска = Новый Структура("НомерСчета, СтавкаНДС", СтрокаТЗСЧФ.НомерСчета, СтрокаТЗСЧФ.СтавкаНДС);
		стрСчета = ТЗСчета.НайтиСтроки(СтруктураПоиска);
		Для Каждого Оплата из стрСчета Цикл
					
			Если СокрЛП(СтрокаТЗСЧФ.ОписаниеЗатрат.Наименование) = "FA" Тогда
				
				Движение = Движения.ОборудованиеЛокальное.Добавить();
				Движение.ВидДвижения		= ВидДвиженияНакопления.Приход;
				Движение.Период				= СтруктураШапкиДокумента.ДатаПроведения; //Было СтрокаТЗСЧФ.ДатаПрихода
				Движение.Поставщик			= СтруктураШапкиДокумента.Контрагент;
				Движение.НомерНакладной		= СтрокаТЗСЧФ.НомерПрихода;
				Движение.ДатаНакладной		= СтрокаТЗСЧФ.ДатаПрихода;
				Движение.AU					= СтрокаТЗСЧФ.AU1C;
				Движение.Подразделение		= СтрокаТЗСЧФ.Подразделение;
				Движение.РО					= оплата.ШвепсПО;
				
				// НЕПОНЯТНО ЗАЧЕМ БЫЛ ВЕСЬ ЭТОТ ГЕМОРРОЙ, ЕСЛИ МОЖНО ВЗЯТЬ РУБЛЕВУЮ СУММУ ПРЯМО ИЗ ТЧ ИЛИ ИЗ СФ!
  //  			Если СтрокаТЗСЧФ.ВалютаПрихода <> мВалютаРегламентированногоУчета Тогда
  //  				
  //  				// Пересчитаем сумму счета в рублях
  //  				// А ТОЧНО ЛИ НАДО ПЕРЕСЧИТЫВАТЬ? МЫ НЕ МОЖЕМ ВЗЯТЬ ИЗ ТЧ?
  //  				СтруктураКурса = ОбщегоНазначения.ПолучитьКурсВалюты(СтрокаТЗСЧФ.ВалютаПрихода, СтрокаТЗСЧФ.ДатаПрихода);
  //  							
  //  				СуммаСНДСРуб = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(СтрокаТЗСЧФ.СуммаСФ, 
  //  								СтрокаТЗСЧФ.ВалютаПрихода, мВалютаРегламентированногоУчета,
  //  								СтруктураКурса.Курс, 1, 
  //  						 		СтруктураКурса.Кратность, 1);
  //
  //  				СуммаНДСРуб = ОбщегоНазначения.РассчитатьСуммуНДС(СуммаСНДСРуб, Истина, Истина,
  //			  						УчетНДС.ПолучитьСтавкуНДС(СтрокаТЗСЧФ.СтавкаНДС));
  //  									
  //  				СуммаБезНДСРуб = СуммаСНДСРуб - СуммаНДСРуб;
  //  				
  //  			Иначе
  //  				
  //  				СуммаБезНДСРуб = СтрокаТЗСЧФ.СуммаБезНДССФ;
  //  									
  //  			КонецЕсли;
									
				Движение.Сумма				= СтрокаТЗСЧФ.СуммаБезНДССФ;
				
			//Закомментировал РГ-Софт - Иванов Антон - 2009-03-27
			//Регистр ДанныеКнигиПокупок не закрывался, да и не использовался, поэтому мы решили его очистить до тех пор пока не заработает Inventory
	
			//ИначеЕсли СтрокаТЗСЧФ.ОписаниеЗатрат.Родитель.Наименование = "SERV" тогда
			//	
			//	Продолжить;
			//	
			//Иначе
			//		
			//	Движение 				= Движения.ДанныеКнигиПокупок.Добавить();
			//	Движение.Период 		= ДатаПП;
			//	Движение.НомерСчета 	= стр.НомерСчета;
			//	Движение.Документ		= Ссылка;
			//	Движение.ОписаниеЗатрат	= стр.ОписаниеЗатрат;
			//	Движение.НомерПрихода	= стр.номерПрихода;
			//	//Движение.ДатаПрихода	= стр.ДатаРегистрацииПрихода;
			//	Движение.ДатаПрихода	= стр.ДатаПрихода;
			//	Движение.Поставщик 		= Контрагент;
			//	
			//	СуммаНДСДвиж = ОбщегоНазначения.РассчитатьСуммуНДС(стр.СуммаПрихода,
			//									   Истина, 
			//									   Истина,
			//									   УчетНДС.ПолучитьСтавкуНДС(стр.СтавкаНДС));

			//	Движение.Сумма		    = стр.СуммаПрихода - СуммаНДСДвиж;
			//	Движение.ПлатежныйЦентр	= CashCode.ПлатежныйЦентр;
			//	Движение.НомерВаучера	= оплата.НомерВаучера;
			//	Движение.ПО 			= оплата.ШвепсПО;
			//	Движение.Валюта			= стр.ВалютаПрихода;
			//	Движение.Организация	= Организация;
					
			КонецЕсли; //Если СокрЛП(СтрокаТЗСЧФ.ОписаниеЗатрат.Наименование) = "FA"
		
		КонецЦикла; // Для Каждого Оплата из стрСчета
		
	КонецЦикла; // Для Каждого СтрокаТЗСЧФ из ТЗСЧФ Цикл
				
КонецПроцедуры // ДвиженияПоРегистрам()

Процедура ДвиженияПоУплатеНДС(СтруктураШапкиДокумента, ТаблицаПоСчетам, Отказ, Заголовок)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаДляПроведенияПоНДСПокупкиУпр = Движения.НДСПокупкиУпр.ВыгрузитьКолонки();
	
	Для Каждого СтрокаСчетов Из ТаблицаПоСчетам Цикл
		
		// Формируем таблицу для проведения по регистру НДСПокупкиУПР
		СтрокаСобытияПолученСчетФактура = ТаблицаДляПроведенияПоНДСПокупкиУпр.Добавить();
		СтрокаСобытияПолученСчетФактура.Событие 		= Перечисления.СобытияПоНДСПокупки.ПолученСчетФактура;
		СтрокаСобытияПолученСчетФактура.Организация 	= СтруктураШапкиДокумента.Организация;
		СтрокаСобытияПолученСчетФактура.Период 			= СтруктураШапкиДокумента.ДатаПроведения; // Была ДатаПП
		СтрокаСобытияПолученСчетФактура.НомерСчета 		= СтрокаСчетов.НомерСчета;
		СтрокаСобытияПолученСчетФактура.НомерСФ 		= СтрокаСчетов.НомерСчета;
		//??? ЭТО ЧТО??? ЭТО ЖЕ ДАТА? ЗАЧЕМ ЕЙ ПРИСВАИВАТЬ СТРОКУ??? И ДАЛЬШЕ ТОЖЕ...
		СтрокаСобытияПолученСчетФактура.ДатаСФ 			= "";
		СтрокаСобытияПолученСчетФактура.Поставщик 		= СтруктураШапкиДокумента.Контрагент;
		СтрокаСобытияПолученСчетФактура.Валюта			= СтруктураШапкиДокумента.Валюта;
		СтрокаСобытияПолученСчетФактура.СуммаБезНДС    	= СтрокаСчетов.СуммаОплатыБезНДСРуб;
		СтрокаСобытияПолученСчетФактура.НДС   			= СтрокаСчетов.СуммаНДСОплатыРуб;
		СтрокаСобытияПолученСчетФактура.СтавкаНДС		= СтрокаСчетов.СтавкаНДС;             
		//Движение.Подразделение	= строка.Подразделение;
		//Движение.БухСчет		= строка.БухСчет;
		//Движение.AU				= строка.AU;
		СтрокаСобытияПолученСчетФактура.CashCode		= СтруктураШапкиДокумента.CashCode;
		СтрокаСобытияПолученСчетФактура.НомерВаучера	= СтрокаСчетов.НомерВаучера;
		СтрокаСобытияПолученСчетФактура.НалоговыйПериод	= СтруктураШапкиДокумента.НалоговыйПериод;
		
		СтрокаСобытияПредъявленНДСПоставщиком = ТаблицаДляПроведенияПоНДСПокупкиУпр.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаСобытияПредъявленНДСПоставщиком, СтрокаСобытияПолученСчетФактура, , "Событие");
		СтрокаСобытияПредъявленНДСПоставщиком.Событие	= Перечисления.СобытияПоНДСПокупки.ПредъявленНДСПоставщиком;
		
		СтрокаСобытияНДСОплачен = ТаблицаДляПроведенияПоНДСПокупкиУпр.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаСобытияНДСОплачен, СтрокаСобытияПолученСчетФактура, , "Событие");
		СтрокаСобытияНДСОплачен.Событие					= Перечисления.СобытияПоНДСПокупки.НДСОплачен;
		
		
		//Делаем движения по регистру НДСНачисленный
		СтрокаДвижений_НДСНачисленный 				= Движения.НДСНачисленный.Добавить();
		СтрокаДвижений_НДСНачисленный.ВидДвижения				= ВидДвиженияНакопления.Приход;
		СтрокаДвижений_НДСНачисленный.Период					= СтруктураШапкиДокумента.ДатаПроведения; //Была ДатаПП
		СтрокаДвижений_НДСНачисленный.Организация				= СтруктураШапкиДокумента.Организация;
		СтрокаДвижений_НДСНачисленный.Покупатель				= СтруктураШапкиДокумента.Нерезидент;
		СтрокаДвижений_НДСНачисленный.СчетФактура				= Ссылка;
		СтрокаДвижений_НДСНачисленный.ВидЦенности				= Перечисления.ВидыЦенностей.НалоговыйАгентИностранцы;
		СтрокаДвижений_НДСНачисленный.СтавкаНДС					= СтрокаСчетов.СтавкаНДС;
		//СтрокаДвижений_НДСНачисленный.СчетУчетаНДС			= ПланыСчетов.Хозрасчетный.НДСУплаченныйАгенту;					
		СтрокаДвижений_НДСНачисленный.СуммаБезНДС				= СтрокаСчетов.СуммаОплатыБезНДСРуб;
		СтрокаДвижений_НДСНачисленный.НДС						= СтрокаСчетов.СуммаНДСОплатыРуб;					
		СтрокаДвижений_НДСНачисленный.Событие					= Перечисления.СобытияПоНДСПродажи.НДСНачисленКУплате;
		СтрокаДвижений_НДСНачисленный.ДатаСобытия 				= СтруктураШапкиДокумента.ДатаПроведения;	//Была ДатаПП
		СтрокаДвижений_НДСНачисленный.ИнвойсинговыйЦентр		= Справочники.ИнвойсинговыеЦентры.НайтиПоНаименованию("Moscow");
		СтрокаДвижений_НДСНачисленный.ПодразделениеОрганизации	= Справочники.ПодразделенияОрганизаций.НайтиПоНаименованию("Москва");					
		СтрокаДвижений_НДСНачисленный.ВидНачисления				= Перечисления.НДСВидНачисления.НДСНачисленКУплате;

	КонецЦикла;
	
	Движения.НДСПокупкиУпр.Загрузить(ТаблицаДляПроведенияПоНДСПокупкиУпр);
			
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ДРУГИЕ ПРОЦЕДУРЫ, ФУНКЦИИ

Функция СформироватьСтрокуНомеров(ТЧ, НазваниеКолонки)
	
	ТЗ = ТЧ.Выгрузить();
	ТЗ.Свернуть(НазваниеКолонки);
	МассивНомеров = ТЗ.ВыгрузитьКолонку(НазваниеКолонки);
	СтрокаНомеров = "";
	Для каждого ТекНомер из МассивНомеров Цикл
		СтрокаНомеров = СтрокаНомеров + СокрЛП(ТекНомер) + ", ";
	КонецЦикла;	
	
	Если стрДлина(СтрокаНомеров) > 2 Тогда
		СтрокаНомеров = Лев(СтрокаНомеров, СтрДлина(СтрокаНомеров) - 2);
	Иначе 
		СтрокаНомеров = "";
	КонецЕсли;
	
	Возврат СтрокаНомеров;

КонецФункции


////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ДОКУМЕНТА

Процедура ОбработкаЗаполнения(Основание)
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ПлатежноеПоручениеИсходящее") тогда  //добавлено для 8.2  РГ-Софт - Петроченко
	//Если Основание.Метаданные().Имя = "ПлатежноеПоручениеИсходящее" тогда
		
		ОбщегоНазначения.ЗаполнитьШапкуДокумента(ЭтотОбъект, ПараметрыСеанса.ТекущийПользователь, , "Продажа");
		ОбщегоНазначения.УстановитьНомерДокумента(ЭтотОбъект);
		УстановитьВремя(РежимАвтоВремя.Последним);
		ДатаПроведения=Основание.Дата;
		Контрагент = Основание.Контрагент;
		НомерПП = Основание.Номер;
		Валюта=мВалютаРегламентированногоУчета;
		Платежка = Основание;
		СуммаПлатежа = Основание.СуммаДокумента;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью()
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Установим реквизит Номера счетов
	ТекущиеНомераСчетов = СформироватьСтрокуНомеров(Счета, "НомерСчета");
	ТекущиеНомераСчетов = Лев(ТекущиеНомераСчетов, 200);
	ОбщегоНазначения.УстановитьЗначение(НомераСчетов, ТекущиеНомераСчетов);
	
	// Установим реквизит Номера ваучеров
	ТекущиеНомераВаучеров = СформироватьСтрокуНомеров(Счета, "НомерВаучера");
	ТекущиеНомераВаучеров = Лев(ТекущиеНомераВаучеров, 200);
	ОбщегоНазначения.УстановитьЗначение(НомераВаучеров, ТекущиеНомераВаучеров);
	
	// ЭТО ЕЩЕ НУЖНО???
	// Установим реквизит Номер СФ
	//ТекущиеНомераСФ = СформироватьСтрокуНомеров(СчетаФактуры, "НомерСФ");
	//ОбщегоНазначения.УстановитьЗначение(НомераСФ, ТекущиеНомераСФ);
			
	//// Установим реквзит Номера актов
	//ТекущиеНомераАктов = СформироватьСтрокуНомеров(СчетаФактуры, "НомерПрихода");
	//ОбщегоНазначения.УстановитьЗначение(НомераАктов, ТекущиеНомераАктов);
	
	// Заполним итоговые суммы
	ОбщегоНазначения.УстановитьЗначение(СуммаСчетов, Счета.Итог("СуммаОплатыСНДСРуб"));
	
	// ЭТО ЕЩЕ НУЖНО???
	//ОбщегоНазначения.УстановитьЗначение(СуммаСФ, СчетаФактуры.Итог("СуммаСФРуб"));
	//ОбщегоНазначения.УстановитьЗначение(СуммаАктов, СчетаФактуры.Итог("СуммаПриходаРуб"));
	
	мУдалятьДвижения = НЕ ЭтоНовый();
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Перем ТаблицаПоСчетам, ТаблицаПоСФ;
		
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ,, Истина);
	КонецЕсли;
		
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
	//Сформируем структуру шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
		
	// Подготовим таблицы документа
	ПодготовитьТаблицуПоСчетам(СтруктураШапкиДокумента, ТаблицаПоСчетам, Отказ, Заголовок);
	
	Если ВидОперации = Перечисления.ВидыОперацийРегистрацияПП.УплатаНДС Тогда
		
		ДвиженияПоУплатеНДС(СтруктураШапкиДокумента, ТаблицаПоСчетам, Отказ, Заголовок);
		Возврат;
		
	КонецЕсли;
	
	ПодготовитьТаблицуПоСФ(СтруктураШапкиДокумента, ТаблицаПоСФ, Отказ, Заголовок);
	
	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	// Проверим правильность заполнения табличных частей
	ПроверитьЗаполнениеТабличныхЧастей(СтруктураШапкиДокумента, ТаблицаПоСчетам, ТаблицаПоСФ, Отказ, Заголовок);
	
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоСчетам, ТаблицаПоСФ, Отказ, Заголовок);
	КонецЕсли;
	
КонецПроцедуры

//Добавил РГ-Софт - Пронин Иван
Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ,, Истина);
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
УчетОшибокЗаполнения.ИнициализироватьСтруктуруДанныхОшибокЗаполнения(ЭтотОбъект);

