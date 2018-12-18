
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS()  Тогда 
		Сообщить("Заявка будет отменена только в 1C, автоматической отмены в TMS не произойдет!");
	Иначе 
		Сообщить("Transport request will be cancelled only in 1C, nothing will be changed in TMS.!");
	КонецЕсли;
	
	CancelOBToTMS(ПараметрКоманды);
	
	Оповестить("OBSentToTMS", , ПараметрКоманды);
	ОповеститьОбИзменении(ПараметрКоманды);
	                      
КонецПроцедуры

&НаСервере
Процедура CancelOBToTMS(TransportRequest)
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	TransportRequestОбъект = TransportRequest.ПолучитьОбъект();
	TransportRequestОбъект.SentToTMS = Ложь;
	TransportRequestОбъект.ДополнительныеСвойства.Вставить("ToTMS");
	// { RGS AArsentev 5/29/2017 3:55:52 PM - S-I-0003092
	TransportRequestОбъект.TMSOBNumber = Неопределено;
	TransportRequestОбъект.SegmentLawson = Неопределено;
	TransportRequestОбъект.ActivityLawson = Неопределено;
	// } RGS AArsentev 5/29/2017 3:55:55 PM - S-I-0003092
	TransportRequestОбъект.Записать();
	
	ЗафиксироватьТранзакцию();
	
	УстановитьПривилегированныйРежим(Ложь);

КонецПроцедуры
