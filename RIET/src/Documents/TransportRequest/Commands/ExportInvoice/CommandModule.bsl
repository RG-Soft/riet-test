
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Для Каждого TransportRequest из ПараметрКоманды Цикл  
		Если НЕ ОбщегоНазначения.ЗначениеРеквизитаОбъекта(TransportRequest, "Проведен") Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"" + СокрЛП(TransportRequest) + " is not accepted by specialist!", , ,);
			Возврат;
		КонецЕсли;
	КонецЦикла;

	УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(
			"Документ.TransportRequest", 
			"ExportInvoice", 
			ПараметрКоманды,
			ПараметрыВыполненияКоманды);
				
КонецПроцедуры
	
