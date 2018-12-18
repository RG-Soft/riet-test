
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Stage = ОпределитьStage(ПараметрКоманды);
	// { RGS AArsentev 18.09.2017 S-I-0003597
	//Если Stage = ПредопределенноеЗначение("Перечисление.TransportRequestStages.CompletelyDelivered") Тогда
	// } RGS AArsentev 18.09.2017 S-I-0003597
		SendOBToTMS(ПараметрКоманды);
	
		Оповестить("OBSentToTMS", , ПараметрКоманды);
		ОповеститьОбИзменении(ПараметрКоманды);
	// { RGS AArsentev 18.09.2017 S-I-0003597
	//иначе
	//	
	//	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS()  Тогда 
	//		Сообщить("Текущий статус заявки: '"+ СокрЛП(Stage) +"'. 
	//		|Только полностью доставленные заявки могут быть отпрвлены в TMS!");
	//	Иначе 
	//		Сообщить("Current transport request stage: '"+ СокрЛП(Stage) +"'. 
	//		|Only completely delivered transport requests can be sent to TMS!");
	//	КонецЕсли;
	//КонецЕсли;
		// } RGS AArsentev 18.09.2017 S-I-0003597

КонецПроцедуры

&НаСервере
Функция ОпределитьStage(TransportRequest)
	
	Возврат РегистрыСведений.StagesOfTransportRequests.ОпределитьStage(TransportRequest);	
	
КонецФункции
	
&НаСервере
Процедура SendOBToTMS(TransportRequest)
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	TransportRequestОбъект = TransportRequest.ПолучитьОбъект();
	TransportRequestОбъект.SentToTMS = Истина;
	Если Не ЗначениеЗаполнено(TransportRequestОбъект.TMSOBNumber) Тогда 
		TransportRequestОбъект.TMSOBNumber = ПолучитьПорядковыйTMSOBNumber(TransportRequestОбъект);
	КонецЕсли;
	TransportRequestОбъект.ДополнительныеСвойства.Вставить("ToTMS");
	TransportRequestОбъект.Записать();
	
	Обработки.PushTransportRequestToTMS.PushTransportRequestToTMS(TransportRequestОбъект);
	
	ЗафиксироватьТранзакцию();
	
	УстановитьПривилегированныйРежим(Ложь);

КонецПроцедуры

&НаСервере
Функция ПолучитьПорядковыйTMSOBNumber(TransportRequestОбъект)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	TransportRequest.TMSOBNumber КАК TMSOBNumber
	               |ИЗ
	               |	Документ.TransportRequest КАК TransportRequest
	               |ГДЕ
	               |	НАЧАЛОПЕРИОДА(TransportRequest.Дата, ДЕНЬ) = &ДатаTR
	               |	И TransportRequest.TMSOBNumber <> """"
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	TMSOBNumber УБЫВ";
	
	Запрос.УстановитьПараметр("ДатаTR", НачалоДня(TransportRequestОбъект.Дата));
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	ДатаСтрокой = Формат(TransportRequestОбъект.Дата, "ДФ=""yMMdd""");
	
	Если СтрДлина(ДатаСтрокой) > 5 Тогда 
		ДатаСтрокой = Прав(ДатаСтрокой, 5);
	КонецЕсли;
		
	Если Выборка.Следующий() Тогда 
		
		НомерПП = Число(Прав(Выборка.TMSOBNumber, 5));
		СледНомер = НомерПП + 1; 
		
		СледНомерСтрокой = СокрЛ(СледНомер);
		Пока СтрДлина(СледНомерСтрокой) < 5 Цикл 
			СледНомерСтрокой = "0" + СледНомерСтрокой;
		КонецЦикла;
		
		Возврат "OBD" + ДатаСтрокой + "-" + СледНомерСтрокой;
		
	Иначе 
		
		Возврат "OBD" + ДатаСтрокой + "-" + "00001";
	
	КонецЕсли;
	          	
КонецФункции

