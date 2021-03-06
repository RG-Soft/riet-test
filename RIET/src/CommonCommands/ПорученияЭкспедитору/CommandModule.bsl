
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Если ТипЗнч(ПараметрКоманды[0]) = Тип("ДокументСсылка.Trip") Тогда 
		ДокументСсылка = "Документ.Trip";
	ИначеЕсли ТипЗнч(ПараметрКоманды[0]) = Тип("ДокументСсылка.ExportRequest") Тогда 
		ДокументСсылка = "Документ.ExportRequest";
	//{ RGS AArsentev S-I-0003188 26.06.2017
	ИначеЕсли ТипЗнч(ПараметрКоманды[0]) = Тип("ДокументСсылка.Поставка") Тогда 
		ДокументСсылка = "Документ.Поставка";
	//} RGS AArsentev S-I-0003188 26.06.2017
	ИначеЕсли ТипЗнч(ПараметрКоманды[0]) = Тип("ДокументСсылка.TripNonLawsonCompanies") Тогда 
		
		ДокументСсылка = "Документ.TripNonLawsonCompanies";
		
		Для Каждого TripСсылка из ПараметрКоманды Цикл 
			
			Если Не ЗначениеЗаполнено(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(TripСсылка, "SentToServiceProviderDate")) Тогда 
				
				SentToServiceProviderDate(TripСсылка);
				
				Оповестить("ЗаписанApproval", , TripСсылка);
				ОповеститьОбИзменении(TripСсылка);
				
			КонецЕсли;
			
		КонецЦикла;
	
	Иначе 
		Возврат;
	КонецЕсли;

	УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(
		ДокументСсылка,
		"APPLICATIONTOTHEFORWARDER", 
		ПараметрКоманды,
		ПараметрыВыполненияКоманды);
	
КонецПроцедуры

Процедура SentToServiceProviderDate(TripСсылка) 
	
	Документы.TripNonLawsonCompanies.SentToServiceProviderDate(TripСсылка);
	
КонецПроцедуры