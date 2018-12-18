
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Для Каждого TripСсылка из ПараметрКоманды Цикл 
		
		Если Не ЗначениеЗаполнено(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(TripСсылка, "SentToServiceProviderDate")) Тогда 
			
			// { RGS AArsentev 13.09.2017 S-I-0003686 - Отправляет автоматически и обновляется при отправке.
			//SentToServiceProviderDate(TripСсылка);
			// } RGS AArsentev 13.09.2017 S-I-0003686
			
			Оповестить("ЗаписанApproval", , TripСсылка);
			ОповеститьОбИзменении(TripСсылка);
			
		КонецЕсли;
		
	КонецЦикла;
	
	УправлениеПечатьюКлиент.ВыполнитьКомандуПечати("Документ.TripNonLawsonCompanies", "WorkOrder", ПараметрКоманды,ПараметрыВыполненияКоманды);
	
КонецПроцедуры

Процедура SentToServiceProviderDate(TripСсылка) 
	
	Документы.TripNonLawsonCompanies.SentToServiceProviderDate(TripСсылка);
	
КонецПроцедуры