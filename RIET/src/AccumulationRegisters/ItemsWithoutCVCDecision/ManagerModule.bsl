
Функция ПолучитьОстаткиПоItems(МоментВремени, Items) Экспорт
	
	// Возвращает таблицу остатков, отобранных по Items
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени);
	Запрос.УстановитьПараметр("Items", Items);
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ItemsWithoutCVCDecisionОстатки.Item,
		|	ItemsWithoutCVCDecisionОстатки.CustomsBond,
		|	ItemsWithoutCVCDecisionОстатки.РесурсОстаток
		|ИЗ
		|	РегистрНакопления.ItemsWithoutCVCDecision.Остатки(&МоментВремени, Item В (&Items)) КАК ItemsWithoutCVCDecisionОстатки";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ПолучитьОстаткиПоCustomsBond(ГраницаДляОстатков, CustomsBond) Экспорт
	
	Если НЕ ЗначениеЗаполнено(CustomsBond) Тогда
		ВызватьИсключение "Customs bond is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("ГраницаДляОстатков", ГраницаДляОстатков);
	Запрос.УстановитьПараметр("CustomsBond", CustomsBond);
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ItemsWithoutCVCDecisionОстатки.Item,
		|	ItemsWithoutCVCDecisionОстатки.РесурсОстаток
		|ИЗ
		|	РегистрНакопления.ItemsWithoutCVCDecision.Остатки(&ГраницаДляОстатков, CustomsBond = &CustomsBond) КАК ItemsWithoutCVCDecisionОстатки";
		
	Возврат Запрос.Выполнить().Выгрузить();
		
КонецФункции