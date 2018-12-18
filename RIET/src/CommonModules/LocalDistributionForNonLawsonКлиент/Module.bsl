
Процедура ОбработкаКомандыCopyTransportRequestWithContentЗавершение(Результат, Параметры) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	НовыйTransportRequest = LocalDistributionForNonLawsonСервер.CopyWithContent(Параметры.ПараметрКоманды);
	Если ЗначениеЗаполнено(НовыйTransportRequest) Тогда
		// { RGS AFokin 06.09.2018 23:59:59 S-I-0005830
		//ПоказатьЗначение(, НовыйTransportRequest);
		ПараметрыОткрытия = Новый Структура("MultiModalCopy", Истина);
		ПараметрыОткрытия.Вставить("Ключ", НовыйTransportRequest);
		ОткрытьФорму("Документ.TransportRequest.Форма.ФормаДокумента", ПараметрыОткрытия, НовыйTransportRequest);
		// } RGS AFokin 06.09.2018 23:59:59 S-I-0005830
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаКомандыCancelApprovalЗавершение(Результат, Параметры) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	LocalDistributionForNonLawsonСервер.CancelApproval(Параметры.Approval);
	
	Оповестить("ЗаписанApproval", , Параметры.Trip);
	ОповеститьОбИзменении(Параметры.Approval);
	
КонецПроцедуры

// { RGS AArsentev 26.07.2018 Multimodal copy
Процедура ОбработкаКомандыMultiModalCopyЗавершение(Результат, Параметры) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	НовыйTransportRequest = LocalDistributionForNonLawsonСервер.CopyWithContent(Параметры.ПараметрКоманды, Истина);
	Если ЗначениеЗаполнено(НовыйTransportRequest) Тогда
		// { RGS AFokin 06.09.2018 23:59:59 S-I-0005830
		//ПоказатьЗначение(, НовыйTransportRequest);
		ПараметрыОткрытия = Новый Структура("MultiModalCopy", Истина);
		ПараметрыОткрытия.Вставить("Ключ", НовыйTransportRequest);
		ОткрытьФорму("Документ.TransportRequest.Форма.ФормаДокумента", ПараметрыОткрытия, НовыйTransportRequest);
		// } RGS AFokin 06.09.2018 23:59:59 S-I-0005830
	КонецЕсли;
	
КонецПроцедуры // } RGS AArsentev 26.07.2018 Multimodal copy