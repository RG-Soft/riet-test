
Перем СамаяРанняяДата; // Раньше этой даты заводить ничего нельзя
Перем ToTMS;

/////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Stage = Перечисления.TransportRequestStages.Draft;
	
	Requestor = ПараметрыСеанса.ТекущийПользователь;

	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ExportRequest") Тогда
		
		ExportRequest = ДанныеЗаполнения.Ссылка;
		
		Дата = ДанныеЗаполнения.Submitted;
		Requestor = ДанныеЗаполнения.Submitter;
		
		// Заполнение шапки
		Country = ДанныеЗаполнения.FromCountry;
		Company = ДанныеЗаполнения.Company;
		LegalEntity = ДанныеЗаполнения.FromLegalEntity;
		SegmentLawson = ДанныеЗаполнения.Segment;
		CostCenter = ДанныеЗаполнения.AU;
		
		Если ТипЗнч(ДанныеЗаполнения.Activity) = Тип("СправочникСсылка.ActivityCodes") Тогда 
			ActivityLawson = ДанныеЗаполнения.Activity;
		иначе
			ActivityLawson = Справочники.ActivityCodes.НайтиПоКоду(СокрЛП(ДанныеЗаполнения.Activity));
		КонецЕсли;

		Activity = СокрЛП(ДанныеЗаполнения.Activity);
		
		Если ДанныеЗаполнения.Urgency = Перечисления.Urgencies.Emergency Тогда 
			// { RGS AFokin 06.09.2018 23:59:59 S-I-0005830
			//Urgency = Справочники.DeliveryUrgency.Emergency;
			Urgency = Справочники.DeliveryUrgency.Critical;
			// } RGS AFokin 06.09.2018 23:59:59 S-I-0005830
		ИначеЕсли ДанныеЗаполнения.Urgency = Перечисления.Urgencies.Urgent Тогда
			// { RGS AFokin 06.09.2018 23:59:59 S-I-0005830
			//Urgency = Справочники.DeliveryUrgency.Urgent;
			Urgency = Справочники.DeliveryUrgency.Critical;
			// } RGS AFokin 06.09.2018 23:59:59 S-I-0005830
		ИначеЕсли ДанныеЗаполнения.Urgency = Перечисления.Urgencies.Standard Тогда
			Urgency = Справочники.DeliveryUrgency.Standard;
		КонецЕсли;
	
		ExternalReference = ДанныеЗаполнения.ExternalReference;
		Если ДанныеЗаполнения.DualUse = Перечисления.YesNo.Yes Тогда 
			DualUse = Истина;
		КонецЕсли;
				
		PayingEntity = Перечисления.PayingEntities.S;
		
		Recharge = ДанныеЗаполнения.Recharge;
		
		Если Recharge Тогда 
			
			PayingEntity = Перечисления.PayingEntities.D;
			
			RechargeType = Перечисления.RechargeType.Internal;
			RechargeToLegalEntity = ДанныеЗаполнения.RechargeToLegalEntity;  
			RechargeToAU = ДанныеЗаполнения.RechargeToAU;
			RechargeToActivity = ДанныеЗаполнения.RechargeToActivity;
						
		КонецЕсли;
	
		//Pick-up
		PickUpFromAddress = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
			ДанныеЗаполнения.PickUpWarehouse, "AddressRus"); 
		PickUpFromContact = ДанныеЗаполнения.PickUpFromContact;
		PickUpFromEmail = ДанныеЗаполнения.PickUpFromEmail;
		PickUpFromPhone = ДанныеЗаполнения.PickUpFromPhone;
		PickUpWarehouse = ДанныеЗаполнения.PickUpWarehouse;
		
		ReadyToShipLocalTime = НачалоДня(ДанныеЗаполнения.ReadyToShipDate) + 60*60*12;

		ReadyToShipUniversalTime = LocalDistributionForNonLawsonСервер.ПолучитьUniversalTime(ReadyToShipLocalTime, PickUpWarehouse);

		//Deliver-to
		DeliverTo = ДанныеЗаполнения.LocalWarehouseTo;
		СтруктураLocalWarehouseTo = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(
			ДанныеЗаполнения.LocalWarehouseTo, "RCACountry,AddressRus,ContactName,ContactEMail,ContactPhone");
		DeliverToCountry = СтруктураLocalWarehouseTo.RCACountry;
		DeliverToAddress = СтруктураLocalWarehouseTo.AddressRus;
		DeliverToContact = СтруктураLocalWarehouseTo.ContactName;
		DeliverToEmail = СтруктураLocalWarehouseTo.ContactEMail;
		DeliverToPhone = СтруктураLocalWarehouseTo.ContactPhone;
		    				
	КонецЕсли;
	         	
КонецПроцедуры
	

/////////////////////////////////////////////////////////////////////////
// ПРИ КОПИРОВАНИИ

Процедура ПриКопировании(ОбъектКопирования)
	
	// Очистим некоторые реквизиты
	RequiredDeliveryLocalTime = Неопределено;
	RequiredDeliveryUniversalTime = Неопределено;
	
	ReadyToShipLocalTime = Неопределено;
	ReadyToShipUniversalTime = Неопределено;

	RequestedLocalTime = Неопределено;
	RequestedUniversalTime = Неопределено;
	
	AcceptedBySpecialistLocalTime = Неопределено;
	AcceptedBySpecialistUniversalTime = Неопределено;
	
	Specialist = Неопределено;
	// { RGS AArsentev 26.07.2018 Multimodal copy
	ParentTR = Неопределено;
	// } RGS AArsentev 26.07.2018 Multimodal copy
	
	Comments = Неопределено;
	
	TMSOBNumber = Неопределено;
	SentToTMS = Ложь;
	
	РГСофт.ОчиститьCreationModification(ЭтотОбъект);

	Stage = Перечисления.TransportRequestStages.Draft;
	
	Если РольДоступна("LocalDistributionSpecialist_ForNonLawsonCompanies") 
		ИЛИ РольДоступна("LocalDistributionOperator_ForNonLawsonCompanies") 
		ИЛИ РольДоступна("LocalDistributionBillingSpecialist_ForNonLawsonCompanies")
		ИЛИ РольДоступна("LocalDistributionAdministrator_ForNonLawsonCompanies") Тогда  
		Requestor = ОбъектКопирования.Requestor;
	иначе
		Requestor = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;                   
	
	// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	ReturnToRequestor = Ложь;
	ReasonForReturn = Неопределено;
	DateRequested = Неопределено;
	Если Urgency = Справочники.DeliveryUrgency.Urgent Тогда
		Urgency = Справочники.DeliveryUrgency.Critical;
	ИначеЕсли Urgency = Справочники.DeliveryUrgency.Emergency Тогда
		Urgency = Справочники.DeliveryUrgency.Critical;
	ИначеЕсли Urgency = Справочники.DeliveryUrgency.Critical Тогда
		Urgency = Справочники.DeliveryUrgency.Critical;
	ИначеЕсли Urgency = Справочники.DeliveryUrgency.Standard Тогда
		Urgency = Справочники.DeliveryUrgency.Standard;
	КонецЕсли;		
	// } RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	
	// { RGS AFokin 24.09.2018 23:59:59 - S-I-0006036
	СохранитьДанныеPickUpFrom = Ложь;
	Если ОбъектКопирования.Company.Country = ОбъектКопирования.Country Тогда 
		СохранитьДанныеPickUpFrom = Истина;
	КонецЕсли;
	СохранитьДанныеDeliverTo = Ложь;	
	Если ОбъектКопирования.Company.Country = ОбъектКопирования.DeliverToCountry Тогда
		СохранитьДанныеDeliverTo = Истина;
	КонецЕсли;	
	
	Если CustomUnionTransaction Тогда
		CustomUnionTransaction = Неопределено;
		// группа "PickUpFrom"
		Если НЕ СохранитьДанныеPickUpFrom Тогда
			Country = ОбъектКопирования.Company.Country;
			Shipper = Неопределено;
			PickUpFrom = Неопределено;
			PickUpWarehouse = Неопределено;
			PickUpFromAddress = Неопределено;
			PickUpFromContact = Неопределено;
			PickUpFromPhone = Неопределено;
			PickUpFromEmail = Неопределено;
		КонецЕсли;
		// группа "DeliverTo"
		Если НЕ СохранитьДанныеDeliverTo Тогда
			DeliverToCountry = ОбъектКопирования.Company.Country;
			CustomUnionTransaction = Неопределено;
			ConsignTo = Неопределено;
			DeliverTo = Неопределено;
			DeliverToAddress = Неопределено;
			DeliverToContact = Неопределено;
			DeliverToPhone = Неопределено;
			DeliverToEmail = Неопределено;
		КонецЕсли;
	КонецЕсли;	
	// { RGS AFokin 24.09.2018 23:59:59 - S-I-0006036
	
	// { RGS LGoncharova 19.11.2018 S-I-0006255
	rgsReasonForTR = Неопределено; 
	// } RGS LGoncharova 19.11.2018 S-I-0006255
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// ПРИ УСТАНОВКЕ НОВОГО НОМЕРА

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	            		
	// S-I-0001644 - закомментировала Петроченко Н.Н.
	// пример TR150709-SM001
	//Если НЕ ЗначениеЗаполнено(Company) Тогда
	//	СтандартнаяОбработка = Ложь;
	//	Возврат;
	//КонецЕсли;
	
	// { RGS AArsentev 28.06.2016 12:30:43 - S-I-0001644
	//Prefix = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(Company, "Prefix");
	  Prefix = "";
	// } RGS AArsentev 28.06.2016 12:30:44 - S-I-0001644

	Префикс = "TR" + Формат(Дата, "ДФ=yyMMdd") + "-" + Prefix;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ДополнительныеСвойства.Свойство("ToTMS") Тогда 
		Возврат;
	КонецЕсли;
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	Если НЕ ЭтоНовый() Тогда
		CurrentStage = РегистрыСведений.StagesOfTransportRequests.ОпределитьStage(Ссылка);
		Если ReturnToRequestor И CurrentStage = Перечисления.TransportRequestStages.Requested Тогда
			ЗарегистрироватьИзменения(Отказ, Ссылка);
			ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью();
			RequestedLocalTime = Неопределено;
			RequestedUniversalTime = Неопределено;
			Возврат;
		КонецЕсли;
	КонецЕсли;	
	// } RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	
	ToTMS = Документы.TransportRequest.ПолучитьСтруктуруCompanySettings(Company, Дата).InTMS;
	        	
	ПроверитьВозможностьИзмененияБезДополнительныхДанных(Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	ДозаполнитьРеквизитыБезДополнительныхДанных();
		
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью();	
	
	ДозаполнитьРеквизитыСДополнительнымиДанными();

	ПроверитьВозможностьИзмененияСДополнительнымиДанными(Отказ);
		
	Если Отказ Тогда
		Возврат;
	КонецЕсли; 
	
	ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи);	
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS AFokin 01.10.2018 23:59:59 - S-I-0006099
	//Если ЗначениеЗаполнено(PickUpWarehouse) И ЗначениеЗаполнено(DeliverTo) Тогда
	ПроверитьСоответствиеRCACoutryДля_ParentCompany_PickUpWarehouse_DeliverTo(Отказ);
	//КонецЕсли;	
	// } RGS AFokin 01.10.2018 23:59:59 - S-I-0006099
	
КонецПроцедуры

Процедура ПроверитьВозможностьИзмененияБезДополнительныхДанных(Отказ)
	
	Если SentToTMS Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Нельзя изменить заявку, отправенную в TMS!
			|Необходимо отменить отправку в TMS, внести изменения и отправить повторно.",
			ЭтотОбъект, , , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"You can not change Transport request, as it is already sent to TMS!
			|Please cancel and send after changes are done.",
			ЭтотОбъект, , , Отказ);
		КонецЕсли;
				
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
				
	Если ЭтоНовый() Тогда	
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);									
	КонецЕсли;
	
	Если ПометкаУдаления Тогда 
		AcceptedBySpecialistLocalTime = Неопределено;
		AcceptedBySpecialistUniversalTime = Неопределено;
	КонецЕсли;
	
	Если НЕ Recharge Тогда
		RechargeType = Неопределено;
		RechargeDetails = Неопределено;
		RechargeToLegalEntity = Неопределено;
		RechargeToAU = Неопределено;
		RechargeToActivity = Неопределено;
		AgreementForRecharge = Неопределено;
		ClientForRecharge = Неопределено;
	иначе 
		Если RechargeType = Перечисления.RechargeType.External Тогда 
			RechargeToLegalEntity = Неопределено;
			RechargeToAU = Неопределено;
			RechargeToActivity = Неопределено;
		иначе 
			AgreementForRecharge = Неопределено;
			ClientForRecharge = Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Requestor) Тогда
		Requestor = ПараметрыСеанса.ТекущийПользователь;	
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(Specialist)
		И ЗначениеЗаполнено(AcceptedBySpecialistLocalTime) Тогда
		Specialist = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;	
	
	Если НЕ CustomUnionTransaction Тогда
		Shipper = Неопределено;
		ConsignTo = Неопределено;
		Incoterms = Неопределено;
		Regime = Неопределено;
		ExportPurpose = Неопределено;
		ExportPurposeDescription = Неопределено;
		//{ RGS AArsentev S-I-0003146 31.05.2017 18:30:15
		AgreementNumber = Неопределено;
		AgreementDate = Неопределено;
		SpecificationNumber = Неопределено;
		SpecificationDate = Неопределено;
		PeriodOfTemporaryExport = Неопределено;
		//} RGS AArsentev S-I-0003146 31.05.2017 18:30:15
	КонецЕсли;
	
	Если AcquisitionCost = Перечисления.YesNo.No И ЗначениеЗаполнено(InventoryPO) Тогда
		InventoryPO = Неопределено;
	КонецЕсли;	
	
		
	СОКРЛПТекстовыхРеквизитов();
	      		   		
КонецПроцедуры

Процедура СОКРЛПТекстовыхРеквизитов()
	
	Если ЗначениеЗаполнено(ActivityLawson) Тогда 
		РГСофтКлиентСервер.УстановитьЗначение(Activity, СокрЛП(ActivityLawson));
	иначе
		РГСофтКлиентСервер.УстановитьЗначение(Activity, СокрЛП(Activity));
	КонецЕсли;

	РГСофтКлиентСервер.УстановитьЗначение(ExternalReference, СокрЛП(ExternalReference));
	РГСофтКлиентСервер.УстановитьЗначение(RechargeToAU, СокрЛП(RechargeToAU));
	РГСофтКлиентСервер.УстановитьЗначение(RechargeToActivity, СокрЛП(RechargeToActivity));
	
	РГСофтКлиентСервер.УстановитьЗначение(PickUpFromAddress, СокрЛП(PickUpFromAddress));
	РГСофтКлиентСервер.УстановитьЗначение(PickUpFromContact, СокрЛП(PickUpFromContact));
	РГСофтКлиентСервер.УстановитьЗначение(PickUpFromPhone, СокрЛП(PickUpFromPhone));
	РГСофтКлиентСервер.УстановитьЗначение(PickUpFromEmail, СокрЛП(PickUpFromEmail));
	
	РГСофтКлиентСервер.УстановитьЗначение(DeliverToAddress, СокрЛП(DeliverToAddress));
	РГСофтКлиентСервер.УстановитьЗначение(DeliverToContact, СокрЛП(DeliverToContact));
	РГСофтКлиентСервер.УстановитьЗначение(DeliverToPhone, СокрЛП(DeliverToPhone));
	РГСофтКлиентСервер.УстановитьЗначение(DeliverToEmail, СокрЛП(DeliverToEmail));
	
	РГСофтКлиентСервер.УстановитьЗначение(NotificationRecipients, СокрЛП(NotificationRecipients));
	РГСофтКлиентСервер.УстановитьЗначение(Comments, СокрЛП(Comments));
	
	РГСофтКлиентСервер.УстановитьЗначение(ExportPurposeDescription, СокрЛП(ExportPurposeDescription)); 
	
КонецПроцедуры

Процедура ДозаполнитьРеквизитыСДополнительнымиДанными()
	
	ВыборкаСтарыхРеквизитовШапки = ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки;
	
	// S-I-0001644 - закомментировала Петроченко Н.Н. 
	//Если Не ЭтоНовый() 
	//	И Не Проведен 
	//	И (ВыборкаСтарыхРеквизитовШапки.Дата <> Дата
	//	ИЛИ ВыборкаСтарыхРеквизитовШапки.Company <> Company) Тогда 
	//	УстановитьНовыйНомер();
	//КонецЕсли;
	
	ТаблицаParcels = ДополнительныеСвойства.ТаблицаParcels;
	Если ТаблицаParcels <> Неопределено Тогда 
		TotalNumOfParcels = ТаблицаParcels.Итог("NumOfParcels");
	КонецЕсли;

КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи)
	     		
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	// Дата
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date / дата заявки' не заполнена!",
			ЭтотОбъект, "Дата", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date / дата заявки' is empty!",
			ЭтотОбъект, "Дата", , Отказ);
		КонецЕсли;

	Иначе
		
		Если Дата > ТекущаяДата() Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Date / дата заявки' не может быть больше текущей даты!",
				ЭтотОбъект, "Дата", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Date / дата заявки' can not be later than current date!",
				ЭтотОбъект, "Дата", , Отказ);
			КонецЕсли;

		КонецЕсли;
		
		Если Дата < СамаяРанняяДата Тогда 
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Date / дата заявки' не может быть раньше """ + Формат(СамаяРанняяДата, "ДЛФ=D") + """",
				ЭтотОбъект, "Дата", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Date / дата заявки' can not be earlier than """ + Формат(СамаяРанняяДата, "ДЛФ=D") + """",
				ЭтотОбъект, "Дата", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
				
	КонецЕсли;
	         		
	// Paying Entity	
	Если НЕ ЗначениеЗаполнено(PayingEntity) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Плательщик'!",
			ЭтотОбъект, "PayingEntity", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Paying entity' is empty!",
			ЭтотОбъект, "PayingEntity", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	// Company
	Если НЕ ЗначениеЗаполнено(Company) Тогда
		  		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Company / компания'!",
			ЭтотОбъект, "Company", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Company / компания' is empty!",
			ЭтотОбъект, "Company", , Отказ);
		КонецЕсли;
			
	Иначе
		
		//RU-компания может забирать грузы из KZ
		
		//// company.Country vs From country
		//Если ЗначениеЗаполнено(Country) Тогда
		//	
		//	CompanyCountry = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(Company, "Country");
		//	Если CompanyCountry <> Country Тогда
		//		
		//		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		//			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		//			"Код страны '" + СокрЛП(CompanyCountry) + "' для компании '" + СокрЛП(Company) + "' отличается от кода страны в заявке '" + СокрЛП(Country) + "'!",
		//			ЭтотОбъект, "Company", , Отказ);
		//		иначе
		//			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		//			"Country code '" + СокрЛП(CompanyCountry) + "' for company '" + СокрЛП(Company) + "' differs from country code in request '" + СокрЛП(Country) + "'!",
		//			ЭтотОбъект, "Company", , Отказ);
		//		КонецЕсли;
		//		
		//	КонецЕсли;
		//	
		//КонецЕсли;
			
	КонецЕсли;
	
	// Country
	Если НЕ ЗначениеЗаполнено(Country) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Country code / код страны отправления'!",
			ЭтотОбъект, "Country", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country code / код страны отправления' is empty!",
			ЭтотОбъект, "Country", , Отказ);
		КонецЕсли;

	КонецЕсли;

	// Deliver-to Country
	Если НЕ ЗначениеЗаполнено(DeliverToCountry) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Код страны назначения'!",
			ЭтотОбъект, "DeliverToCountry", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Deliver-to country code' is empty!",
			ЭтотОбъект, "DeliverToCountry", , Отказ);
		КонецЕсли;

	КонецЕсли;

	//S-I-0002174
	Если ЗначениеЗаполнено(Country) И ЗначениеЗаполнено(DeliverToCountry)
		И (Country = Справочники.CountriesOfProcessLevels.AZ ИЛИ DeliverToCountry = Справочники.CountriesOfProcessLevels.AZ) 
		И Country <> DeliverToCountry Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"В модуле локальной транспортировки следует размещать заявки на перемещение внутри Азербайджана!",
			ЭтотОбъект, , , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"You should request only local transportation for AZ!",
			ЭтотОбъект, , , Отказ);
		КонецЕсли;

	КонецЕсли;

	//S-I-0002694
	Если ЗначениеЗаполнено(Country) И ЗначениеЗаполнено(DeliverToCountry)
		И (Country = Справочники.CountriesOfProcessLevels.TM ИЛИ DeliverToCountry = Справочники.CountriesOfProcessLevels.TM) 
		И Country <> DeliverToCountry Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"В модуле локальной транспортировки следует размещать заявки на перемещение внутри Туркменистана!",
			ЭтотОбъект, , , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"You should request only local transportation for TM!",
			ЭтотОбъект, , , Отказ);
		КонецЕсли;

	КонецЕсли;
	
	// Notification recipients
	Если ЗначениеЗаполнено(NotificationRecipients) Тогда 
		
		МассивСтруктур = ОбщегоНазначенияКлиентСервер.АдресаЭлектроннойПочтыИзСтроки(NotificationRecipients);
		
		МассивNotificationRecipients = Новый Массив;
		Для Каждого Структура из МассивСтруктур Цикл 
			
			Если ЗначениеЗаполнено(Структура.ОписаниеОшибки) Тогда
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"E-mail '" + Структура.Псевдоним + "': " + Структура.ОписаниеОшибки,
					ЭтотОбъект, "NotificationRecipients", , Отказ);
			Иначе 
				МассивNotificationRecipients.Добавить(Структура.Адрес);
			КонецЕсли;
			
		КонецЦикла;
		
		Если Не Отказ Тогда 
			МассивNotificationRecipients = ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(МассивNotificationRecipients);
			NotificationRecipients = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивNotificationRecipients, ";");
		КонецЕсли;

	КонецЕсли;
	
	// { RG-Soft LGoncharova 19.11.2018 S-I-0006255
	Если НЕ ЗначениеЗаполнено(rgsReasonForTR) Тогда
		Проверять = Истина;
		
		Если ДополнительныеСвойства.Свойство("НеПроверятьReasonForTR") Тогда
			Проверять = Ложь;
		КонецЕсли;
		
		Если Проверять Тогда
			ДатаВкл = Неопределено;
			Если ДополнительныеСвойства.Свойство("ДатаВключенияReasonsForTR", ДатаВкл) И Дата < ДатаВкл Тогда
				Проверять = Ложь;
			КонецЕсли;
		КонецЕсли;
		
		Если Проверять Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			НСтр("ru='Не заполнено поле <Причина перемещения>!';en='Field is not filled <Reason for TR>'"),
			ЭтотОбъект, "rgsReasonForTR", , Отказ);
		КонецЕсли;
	КонецЕсли;
	// } RG-Soft LGoncharova 19.11.2018 S-I-0006255
	
	      		
	ПроверитьRequestedБезДополнительныхДанных(Отказ, РежимЗаписи);
	
	ПроверитьAcceptedБезДополнительныхДанных(Отказ, РежимЗаписи);
	
КонецПроцедуры

Процедура ПроверитьRequestedБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если РежимЗаписи = РежимЗаписиДокумента.ОтменаПроведения Тогда 
		Возврат;
	КонецЕсли;
	
	Если (Не ЗначениеЗаполнено(RequestedLocalTime)
		И РежимЗаписи <> РежимЗаписиДокумента.Проведение)
		// { RGS AArsentev 26.07.2018 Multimodal copy
		ИЛИ (ЗначениеЗаполнено(ParentTR) И РежимЗаписи <> РежимЗаписиДокумента.Проведение) Тогда
		// } RGS AArsentev 26.07.2018 Multimodal copy
		Возврат;
	КонецЕсли;
	
	СтруктураCompanySettings = Документы.TransportRequest.ПолучитьСтруктуруCompanySettings(Company, Дата);		
	
	// Legal entity
	Если НЕ ЗначениеЗаполнено(LegalEntity) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Legal entity / Юридическое лицо'!",
			ЭтотОбъект, "LegalEntity", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Legal entity / Юридическое лицо' is empty!",
			ЭтотОбъект, "LegalEntity", , Отказ);
		КонецЕсли;

	Иначе
		
		// legal entity.company vs company
		LegalEntityCompany = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(LegalEntity, "ParentCompany");
		Если LegalEntityCompany <> Company Тогда
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Компания юридического лица '" + СокрЛП(LegalEntityCompany) + "' отличается от компании в заявке '" + СокрЛП(Company) + "'!",
					ЭтотОбъект, "LegalEntity", , Отказ);	
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Company of Legal entity '" + СокрЛП(LegalEntityCompany) + "' differs from company in request '" + СокрЛП(Company) + "'!",
					ЭтотОбъект, "LegalEntity", , Отказ);	
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтруктураCompanySettings.DefaultLegalEntity)
			И LegalEntity <> СтруктураCompanySettings.DefaultLegalEntity  Тогда 
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"За компанией '" + СокрЛП(Company) + "' закреплено другое юридическое лицо '" 
				+ СокрЛП(СтруктураCompanySettings.DefaultLegalEntity) + "'!",
				ЭтотОбъект, "LegalEntity", , Отказ);	
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"For Company '" + СокрЛП(Company) + "' is determined default legal entity '" 
				+ СокрЛП(СтруктураCompanySettings.DefaultLegalEntity) + "'!",
				ЭтотОбъект, "LegalEntity", , Отказ);	
			КонецЕсли;

		КонецЕсли;
		
		Если ToTMS И НЕ РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(LegalEntity, "InTMS") Тогда	
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Юридическое лицо' не в TMS!
				|Выберите 'Юридическое лицо' которое есть TMS.",
				ЭтотОбъект, "LegalEntity", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Legal entity' is not in TMS!
				|Choose 'Legal entity' that is in TMS.",
				ЭтотОбъект, "LegalEntity", , Отказ);
			КонецЕсли;
						
		КонецЕсли;

	КонецЕсли;
	
	// Segment
	Если СтруктураCompanySettings.SpecifySegment Тогда
		
		Если Не ЗначениеЗаполнено(Segment) Тогда 
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Segment / подразделение'!",
				ЭтотОбъект, "Segment", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Segment / подразделение' is empty!",
				ЭтотОбъект, "Segment", , Отказ);
			КонецЕсли;
			
		иначе
			
			Если ЗначениеЗаполнено(LegalEntity) 
				И LegalEntity <> РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(Segment, "Владелец") Тогда 
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Юридическое лицо подразделения '" + СокрЛП(Segment) + "' отличается от юр.лица в заявке '" + СокрЛП(LegalEntity) + "'!",
					ЭтотОбъект, "Segment", , Отказ);	
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Legal entity of segment '" + СокрЛП(Segment) + "' differs from legal entity in request '" + СокрЛП(LegalEntity) + "'!",
					ЭтотОбъект, "Segment", , Отказ);	
				КонецЕсли;  
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Product Line
	Если СтруктураCompanySettings.SpecifyProductLine
		И Не ЗначениеЗаполнено(ProductLine) Тогда 
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Product line / продуктовая линия'!",
			ЭтотОбъект, "ProductLine", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Product line / продуктовая линия' is empty!",
			ЭтотОбъект, "ProductLine", , Отказ);
		КонецЕсли;

	КонецЕсли;

	// Urgency         				
	Если НЕ ЗначениеЗаполнено(Urgency) Тогда	
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Urgency / срочность поставки'!",
			ЭтотОбъект, "Urgency", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Urgency / срочность поставки' is empty!",
			ЭтотОбъект, "Urgency", , Отказ);
		КонецЕсли;
	КонецЕсли;
	
	///////////////////////////////////////////////////////////////
	// Cost Center
	
	// { RGS AArsentev S-I-0001800 22.08.2016 10:22:52

	//Если СтруктураCompanySettings.SpecifyCostCenter = Перечисления.TypesOfCostCenters.LawsonAU
	//	ИЛИ СтруктураCompanySettings.SpecifyCostCenter = Перечисления.TypesOfCostCenters.NonLawsonAU Тогда 
	//	
	//	Если НЕ ЗначениеЗаполнено(CostCenter) Тогда
	//		
	//		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
	//			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//			"Не заполнено поле 'Центр затрат'!",
	//			ЭтотОбъект, "CostCenter", , Отказ);
	//		иначе
	//			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//			"'Cost center' is empty!",
	//			ЭтотОбъект, "CostCenter", , Отказ);
	//		КонецЕсли;
	//		
	//	КонецЕсли;
	//	
	//КонецЕсли;
	
	Если СтруктураCompanySettings.SpecifyCostCenter = Перечисления.TypesOfCostCenters.FromSegment Тогда
		
		Если ЗначениеЗаполнено(Segment) Тогда
			Если НЕ ЗначениеЗаполнено(CostCenter) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Для подразделения "+Segment+" не заполнено поле 'Центр затрат'!",
					ЭтотОбъект, "CostCenter", , Отказ);
			КонецЕсли;
		КонецЕсли;	
		
	ИначеЕсли СтруктураCompanySettings.SpecifyCostCenter = Перечисления.TypesOfCostCenters.DefaultCostCenter Тогда
		
		Если НЕ ЗначениеЗаполнено(CostCenter) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Для выбранной компании не указан 'Центр затрат' по умолчанию",
				ЭтотОбъект, "CostCenter", , Отказ);	
		КонецЕсли;
			
	ИначеЕсли СтруктураCompanySettings.SpecifyCostCenter = Перечисления.TypesOfCostCenters.FromLegalEntity_ProductLine Тогда
		      				
		Если ЗначениеЗаполнено(ProductLine) Тогда
			
			Если ЗначениеЗаполнено(ProductLine.Segment) Тогда
				Если НЕ ЗначениеЗаполнено(CostCenter) Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Нет 'Центра затрат' для указанного в продуктовой линии "+ ProductLine + " сегмента - " + ProductLine.Segment,
					ЭтотОбъект, "CostCenter", , Отказ);
				КонецЕсли;
			Иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не указан 'Segment' для " + ProductLine,
				ЭтотОбъект, "ProductLine", , Отказ);				
			КонецЕсли;
			
		КонецЕсли;
		
	ИначеЕсли СтруктураCompanySettings.SpecifyCostCenter = Перечисления.TypesOfCostCenters.CompanyCostCenters Тогда
		
		Если НЕ ЗначениеЗаполнено(CostCenter) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не выбран 'Центр затрат'",
			ЭтотОбъект, "CostCenter", , Отказ);			
		Иначе				
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			               |	CompaniesСostСentersСрезПоследних.CostCenter
			               |ИЗ
			               |	РегистрСведений.CompaniesСostСenters.СрезПоследних(&Дата, ) КАК CompaniesСostСentersСрезПоследних
			               |ГДЕ
			               |	CompaniesСostСentersСрезПоследних.Company = &Company
			               |	И CompaniesСostСentersСрезПоследних.CostCenter = &CostCenter";
			Запрос.УстановитьПараметр("Company", Company);
			Запрос.УстановитьПараметр("CostCenter", CostCenter);
			Запрос.УстановитьПараметр("Дата",Дата);
			Результат = Запрос.Выполнить().Выбрать();
			Если Результат.Количество() = 0 Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Центр затрат' не соответствует выбранной компании.",
				ЭтотОбъект, "CostCenter", , Отказ);	
			КонецЕсли;
		КонецЕсли;
		
	ИначеЕсли СтруктураCompanySettings.SpecifyCostCenter = Перечисления.TypesOfCostCenters.FromLegalEntity Тогда
		
		Если НЕ ЗначениеЗаполнено(CostCenter) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не выбран 'Центр затрат'",
			ЭтотОбъект, "CostCenter", , Отказ);	
		Иначе
			
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			               |	AUsAndLegalEntitiesСрезПоследних.AU
			               |ИЗ
			               |	РегистрСведений.AUsAndLegalEntities.СрезПоследних(&Дата, ) КАК AUsAndLegalEntitiesСрезПоследних
			               |ГДЕ
			               |	AUsAndLegalEntitiesСрезПоследних.AU = &AU
			               |	И AUsAndLegalEntitiesСрезПоследних.ParentCompany = &ParentCompany
			               |	И AUsAndLegalEntitiesСрезПоследних.LegalEntity = &LegalEntity";
			Запрос.УстановитьПараметр("AU",CostCenter);
			Запрос.УстановитьПараметр("ParentCompany",Company);
			Запрос.УстановитьПараметр("LegalEntity",LegalEntity);
			Запрос.УстановитьПараметр("Дата",Дата);
			Результат = Запрос.Выполнить().Выбрать();
			Если Результат.Количество() = 0 Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Центр затрат' не соответствует выбранной компании и юр.лицу.",
				ЭтотОбъект, "CostCenter", , Отказ);	
			КонецЕсли;	
		КонецЕсли;
		
	ИначеЕсли СтруктураCompanySettings.SpecifyCostCenter = Перечисления.TypesOfCostCenters.LawsonAU Тогда
		
		Если НЕ ЗначениеЗаполнено(CostCenter) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не выбран 'Центр затрат'",
			ЭтотОбъект, "CostCenter", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	// } RGS AArsentev S-I-0001800 22.08.2016 10:22:52

	// Project Client 
	Если Не ЗначениеЗаполнено(ProjectClient) Тогда 
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Project client / заказчик'!",
			ЭтотОбъект, "ProjectClient", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Project client / заказчик' is empty!",
			ЭтотОбъект, "ProjectClient", , Отказ);
		КонецЕсли;

	КонецЕсли;

	// Project Mobilization 
	Если Не ЗначениеЗаполнено(ProjectMobilization) Тогда 
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Project mobilization / проект мобилизации'!",
			ЭтотОбъект, "ProjectMobilization", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Project mobilization / проект мобилизации' is empty!",
			ЭтотОбъект, "ProjectMobilization", , Отказ);
		КонецЕсли;

	иначе
		
		Если ProjectMobilization = Справочники.ProjectMobilization.OFS Тогда 
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Обратите внимание: 'OFS' - служебный проект!",
				ЭтотОбъект, , , );
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Please note 'OFS' is a service project!",
				ЭтотОбъект, , , );
			КонецЕсли;
			
		КонецЕсли;

	КонецЕсли;

	// In TMS
	      
	Если СтруктураCompanySettings.InTMS Тогда 
		
		// Segment Lawson	
		Если НЕ ЗначениеЗаполнено(SegmentLawson) Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Сегмент'!",
				ЭтотОбъект, "SegmentLawson", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Segment' is empty!",
				ЭтотОбъект, "SegmentLawson", , Отказ);
			КонецЕсли;
			
		иначе
			
			// AU.Segment vs Segment
			Если ЗначениеЗаполнено(CostCenter) Тогда
				
				AUSegment = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(CostCenter, "Segment"); 
				
				Если AUSegment <> SegmentLawson Тогда
					Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"Сегмент '" + СокрЛП(AUSegment) + "' центра затрат отличается от сегмента в Заявке!",
						ЭтотОбъект, "CostCenter", , Отказ);
					иначе
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"Segment '" + СокрЛП(AUSegment) + "' in Cost center differs from Segment in Transport request!",
						ЭтотОбъект, "CostCenter", , Отказ);
					КонецЕсли;
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
		// Activity
		
		Если НЕ ЗначениеЗаполнено(ActivityLawson) Тогда
			    Сообщить("1");
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Код проекта'!",
				ЭтотОбъект, "ActivityLawson", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Activity' is empty!",
				ЭтотОбъект, "ActivityLawson", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		        				
	КонецЕсли;
	
	// Acquisition Cost
	Если СтруктураCompanySettings.SpecifyAcquisitionCost Тогда
		
		Если НЕ ЗначениеЗаполнено(AcquisitionCost) Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Стоимость приобретения'!",
				ЭтотОбъект, "AcquisitionCost", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Acquisition cost' is empty!",
				ЭтотОбъект, "AcquisitionCost", , Отказ);
			КонецЕсли; 
			
		иначе
			
			Если AcquisitionCost = Перечисления.YesNo.Yes И Recharge Тогда  //S-I-0001830
			
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Нельзя указывать перевыставление для стоимости приобретения!",
					ЭтотОбъект, "AcquisitionCost", , Отказ);
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"You can not mark Recharge if Acquisition cost is yes!",
					ЭтотОбъект, "AcquisitionCost", , Отказ);
				КонецЕсли; 
			
			КонецЕсли;

		КонецЕсли;
		
	КонецЕсли;
	
	// Recharge details
	Если Recharge Тогда
		
		Если RechargeType = Перечисления.RechargeType.External Тогда 
			
			Если СтруктураCompanySettings.SpecifyAgreementForRecharge Тогда 
				
				ClientForRecharge = Неопределено; //на будущее, contractors нужно будет смэтчить с каталогом клиентов

				Если НЕ ЗначениеЗаполнено(AgreementForRecharge) Тогда
					
					Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"Не заполнено поле 'Соглашение для перевыставления'!",
						ЭтотОбъект, "AgreementForRecharge", , Отказ);
					иначе
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"'Agreement for re-charge' is empty!",
						ЭтотОбъект, "AgreementForRecharge", , Отказ);
					КонецЕсли;
					
				КонецЕсли;
				   							
			иначе
				
				AgreementForRecharge = Неопределено;
				
				Если НЕ ЗначениеЗаполнено(ClientForRecharge) Тогда
					
					Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"Не заполнено поле 'Заказчик для перевыставления'!",
						ЭтотОбъект, "ClientForRecharge", , Отказ);
					иначе
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"'Client for re-charge' is empty!",
						ЭтотОбъект, "ClientForRecharge", , Отказ);
					КонецЕсли;
					
				КонецЕсли;
				
			КонецЕсли;
		
		ИначеЕсли RechargeType = Перечисления.RechargeType.Internal Тогда 
			
			Если НЕ ЗначениеЗаполнено(RechargeToLegalEntity) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Не заполнено поле 'Юр. лицо для перевыставления'!",
					ЭтотОбъект, "RechargeToLegalEntity", , Отказ);
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Recharge to legal entity' is empty!",
					ЭтотОбъект, "RechargeToLegalEntity", , Отказ);
				КонецЕсли;
				
			иначе
				
				Если ToTMS И НЕ РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(RechargeToLegalEntity, "InTMS") Тогда	
					
					Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"'Юр. лицо для перевыставления' не в TMS!
						|Выберите 'Юр. лицо для перевыставления' которое есть TMS.",
						ЭтотОбъект, "RechargeToLegalEntity", , Отказ);
					иначе
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"'Recharge to legal entity' is not in TMS!
						|Choose 'Recharge to legal entity' that is in TMS.",
						ЭтотОбъект, "RechargeToLegalEntity", , Отказ);
					КонецЕсли;
					
				КонецЕсли;
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(RechargeToAU) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Не заполнено поле 'Центр затрат для перевыставления'!",
					ЭтотОбъект, "RechargeToAU", , Отказ);
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Recharge to cost center' is empty!",
					ЭтотОбъект, "RechargeToAU", , Отказ);
				КонецЕсли;
				
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(RechargeToActivity) Тогда
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Не заполнено поле 'Код проекта для перевыставления'!",
					ЭтотОбъект, "RechargeToActivity", , Отказ);
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Recharge to activity' is empty!",
					ЭтотОбъект, "RechargeToActivity", , Отказ);
				КонецЕсли;
				
			КонецЕсли;
			
		иначе
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Тип перевыставления'!",
				ЭтотОбъект, "RechargeType", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Recharge type' is empty!",
				ЭтотОбъект, "RechargeType", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	////////////////////////////////////////////////////////////
	// Pick Up
	Если НЕ ЗначениеЗаполнено(PickUpWarehouse) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Pick-up From / место отправления'!",
			ЭтотОбъект, "PickUpWarehouse", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Pick-up From / место отправления' is empty!",
			ЭтотОбъект, "PickUpWarehouse", , Отказ);
		КонецЕсли;

	Иначе
		
		// Pick up warhouse.RCA country vs From country
		Если PickUpWarehouse <> Справочники.Warehouses.Other И ЗначениеЗаполнено(Country) Тогда
			
			PickUpWarehouseRCACountry = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(PickUpWarehouse, "RCACountry");
			Если PickUpWarehouseRCACountry <> Country Тогда
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Код страны '" + СокрЛП(PickUpWarehouseRCACountry) + "' места отправления '" + СокрЛП(PickUpWarehouse) + "' отличается от кода страны '" + СокрЛП(Country) + "'!",
					ЭтотОбъект, "PickUpWarehouse", , Отказ);
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Country code '" + СокрЛП(PickUpWarehouseRCACountry) + "' of pick-up from '" + СокрЛП(PickUpWarehouse) + "' differs from country code '" + СокрЛП(Country) + "'!",
					ЭтотОбъект, "PickUpWarehouse", , Отказ);
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
		Если ToTMS И НЕ РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(PickUpWarehouse, "InTMS") Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Место отправления (локация)' не в TMS!
					|Выберите 'Место отправления (локацию)' которое есть TMS.",
					ЭтотОбъект, "PickUpWarehouse", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Pick up warehouse' is not in TMS!
					|Choose 'Pick up warehouse' that is in TMS.",
					ЭтотОбъект, "PickUpWarehouse", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли; 
	
	// Pick up from address
	Если НЕ ЗначениеЗаполнено(PickUpFromAddress) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Pick up from address / адрес отправления'!",
			ЭтотОбъект, "PickUpFromAddress", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Pick up from address / адрес отправления' is empty!",
			ЭтотОбъект, "PickUpFromAddress", , Отказ);
		КонецЕсли;

	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(PickUpFromContact) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Pick up from contact name / контактное лицо места отправления'!",
			ЭтотОбъект, "PickUpFromContact", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Pick up from contact name / контактное лицо места отправления' is empty!",
			ЭтотОбъект, "PickUpFromContact", , Отказ);
		КонецЕсли;

	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(PickUpFromPhone) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Pick up from phone / тел. номер места отправления'!",
			ЭтотОбъект, "PickUpFromPhone", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Pick up from phone / тел. номер места отправления' is empty!",
			ЭтотОбъект, "PickUpFromPhone", , Отказ);
		КонецЕсли;

	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ReadyToShipLocalTime) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Ready to ship time (local) / время готовности груза к отправке (местное)'!",
			ЭтотОбъект, "ReadyToShipLocalTime", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Ready to ship time (local) / время готовности груза к отправке (местное)' is empty!",
			ЭтотОбъект, "ReadyToShipLocalTime", , Отказ);
		КонецЕсли;

	иначе
		
		Если НЕ ЗначениеЗаполнено(ReadyToShipUniversalTime) Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Ready to ship time (universal) / время готовности груза к отправке (универсальное)'!
				|Пожалуйста сообщите об ошибке: riet-support-ld@slb.com",
				ЭтотОбъект, "ReadyToShipUniversalTime", , Отказ);	
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Ready to ship time (universal) / время готовности груза к отправке (универсальное)' is empty!
				|Please contact riet-support-ld@slb.com",
				ЭтотОбъект, "ReadyToShipUniversalTime", , Отказ);	
			КонецЕсли;

		КонецЕсли;
		      				
	КонецЕсли;
	
	////////////////////////////////////////////////////////////
	// Deliver-to 	
	        		
	Если CustomUnionTransaction Тогда 
		
		Если НЕ ЗначениеЗаполнено(ExportPurpose) Тогда	
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Назначение поставки'!",
				ЭтотОбъект, "ExportPurpose", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Purpose of shipment' is empty!",
				ЭтотОбъект, "ExportPurpose", , Отказ);				
			КонецЕсли;
			
		КонецЕсли;

		Если ExportPurpose = Справочники.ExportPurposes.Other И НЕ ЗначениеЗаполнено(ExportPurposeDescription) Тогда	
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Описание назначения поставки'!",
				ЭтотОбъект, "ExportPurposeDescription", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Purpose description' is empty!",
				ЭтотОбъект, "ExportPurposeDescription", , Отказ);	
			КонецЕсли;
			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Shipper) Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Отправитель'!",
				ЭтотОбъект, "Shipper", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Shipper' is empty!",
				ЭтотОбъект, "Shipper", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ConsignTo) Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Получатель'!",
				ЭтотОбъект, "ConsignTo", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Consign to' is empty!",
				ЭтотОбъект, "ConsignTo", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		
		//{ RGS AArsentev S-I-0003146 31.05.2017 18:30:15
		// { RGS AArsentev 11.01.2018 S-I-0004118
		ExportPurpose_Return = Справочники.ExportPurposes.НайтиПоКоду("RET");
		Если Regime = Перечисления.PermanentTemporary.Temporary И ЗначениеЗаполнено(ExportPurpose_Return) И ExportPurpose = ExportPurpose_Return Тогда
		// } RGS AArsentev 11.01.2018 S-I-0004118
		ИначеЕсли Regime = Перечисления.PermanentTemporary.Temporary И НЕ ЗначениеЗаполнено(PeriodOfTemporaryExport) Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Срок временного ввоза'!",
				ЭтотОбъект, "PeriodOfTemporaryExport", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Period of temporary export' is empty!",
				ЭтотОбъект, "PeriodOfTemporaryExport", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		//} RGS AArsentev S-I-0003146 31.05.2017 18:30:15
		
		// { RGS AArsentev 13.04.2018
		ПроверятьAgreement = Документы.TransportRequest.ПроверитьСоответствиеCompanyLE(Shipper, ConsignTo);
		// } RGS AArsentev 13.04.2018
		// { RGS AArsentev S-I-0004715 26.03.2018
		Если НЕ ЗначениеЗаполнено(AgreementNumber) И ПроверятьAgreement Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле '№ соглашения'!",
				ЭтотОбъект, "AgreementNumber", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Agreement number' is empty!",
				ЭтотОбъект, "AgreementNumber", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(AgreementDate) И ПроверятьAgreement Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Дата соглашения'!",
				ЭтотОбъект, "AgreementDate", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Agreement date' is empty!",
				ЭтотОбъект, "AgreementDate", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		// } RGS AArsentev S-I-0004715 26.03.2018
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(DeliverTo) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Deliver-to / место доставки'!",
			ЭтотОбъект, "DeliverTo", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Deliver-to / место доставки' is empty!",
			ЭтотОбъект, "DeliverTo", , Отказ);
		КонецЕсли;
		
	Иначе	
		
		// Deliver-to .RCA country vs From country
		Если DeliverTo <> Справочники.Warehouses.Other И ЗначениеЗаполнено(DeliverToCountry) Тогда
			
			DeliverToRCACountry = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(DeliverTo, "RCACountry");
			Если DeliverToRCACountry <> DeliverToCountry Тогда
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Код страны '" + СокрЛП(DeliverToRCACountry) + "' места прибытия '" + СокрЛП(DeliverTo) + "' отличается от кода страны '" + СокрЛП(DeliverToCountry) + "'!",
					ЭтотОбъект, "DeliverTo", , Отказ);
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Country code '" + СокрЛП(DeliverToRCACountry) + "' of deliver-to '" + СокрЛП(DeliverTo) + "' differs from country code '" + СокрЛП(DeliverToCountry) + "'!",
					ЭтотОбъект, "DeliverTo", , Отказ);
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		      		
		Если ToTMS И НЕ РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(DeliverTo, "InTMS") Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Место отправления (локация)' не в TMS!
					|Выберите 'Место отправления (локацию)' которое есть TMS.",
					ЭтотОбъект, "DeliverTo", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Deliver-to' is not in TMS!
					|Choose 'Deliver-to' that is in TMS.",
					ЭтотОбъект, "DeliverTo", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
	
	КонецЕсли;
	
	// Deliver-to address
	Если НЕ ЗначениеЗаполнено(DeliverToAddress) Тогда
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Deliver-to address / адрес доставки'!",
			ЭтотОбъект, "DeliverToAddress", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Deliver-to address / адрес доставки' is empty!",
			ЭтотОбъект, "DeliverToAddress", , Отказ);
		КонецЕсли;
	КонецЕсли;
	
	// Deliver-to contact
	Если НЕ ЗначениеЗаполнено(DeliverToContact) Тогда
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Deliver-to contact name / контактное лицо места доставки'!",
			ЭтотОбъект, "DeliverToContact", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Deliver-to contact name / контактное лицо места доставки' is empty!",
			ЭтотОбъект, "DeliverToContact", , Отказ);
		КонецЕсли;
	КонецЕсли;
	
	// Deliver-to phone
	Если НЕ ЗначениеЗаполнено(DeliverToPhone) Тогда
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Deliver-to phone / тел. номер места доставки'!",
			ЭтотОбъект, "DeliverToPhone", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Deliver-to phone / тел. номер места доставки' is empty!",
			ЭтотОбъект, "DeliverToPhone", , Отказ);
		КонецЕсли;
	КонецЕсли;
	   		
	// Required delivery date
	Если НЕ ЗначениеЗаполнено(RequiredDeliveryLocalTime) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Required delivery time (local) / требуемое время доставки (местное)'!",
			ЭтотОбъект, "RequiredDeliveryLocalTime", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Required delivery time (local) / требуемое время доставки (местное)' is empty!",
			ЭтотОбъект, "RequiredDeliveryLocalTime", , Отказ);
		КонецЕсли;

	Иначе
	
		Если RequiredDeliveryUniversalTime <= ReadyToShipUniversalTime Тогда 
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Required delivery time (local) / требуемое время доставки' не может быть раньше (или равно) 'Ready to ship time (local) / время готовности груза к отправке'!",
				ЭтотОбъект, "RequiredDeliveryLocalTime", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Required delivery time (local) / требуемое время доставки' can not be earlier (or equal) 'Ready to ship time (local) / время готовности груза к отправке'!",
				ЭтотОбъект, "RequiredDeliveryLocalTime", , Отказ);
			КонецЕсли;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(RequiredDeliveryUniversalTime) Тогда
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не заполнено поле 'Ready to ship time (universal) / время готовности груза к отправке (универсальное)'!
				|Пожалуйста сообщите об ошибке: riet-support-ld@slb.com",
				ЭтотОбъект, "RequiredDeliveryUniversalTime", , Отказ);	
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Ready to ship time (universal) / время готовности груза к отправке (универсальное)' is empty!
				|Please contact riet-support-ld@slb.com",
				ЭтотОбъект, "RequiredDeliveryUniversalTime", , Отказ);	
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	// Specialist
	Если НЕ ЗначениеЗаполнено(Specialist) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Logistics specialist / специалист отдела логистики'!",
			ЭтотОбъект, "Specialist", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Logistics specialist / специалист отдела логистики' is empty!",
			ЭтотОбъект, "Specialist", , Отказ);
		КонецЕсли;
	// { RGS AArsentev 31.07.2018
	Иначе
		ПроверитьСпециалиста(Отказ);
	// } RGS AArsentev 31.07.2018
	КонецЕсли;
	
	// { RGS AArsentev S-I-0001855 06.09.2016 23:38:52
	// Regime
	Если CustomUnionTransaction И НЕ ЗначениеЗаполнено(Regime) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Режим ввоза'!",
			ЭтотОбъект, "Regime", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Regime' is empty!",
			ЭтотОбъект, "Regime", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	   	
	//InventoryPO
	Если AcquisitionCost = Перечисления.YesNo.Yes И НЕ ЗначениеЗаполнено(InventoryPO) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'InventoryPO'!",
			ЭтотОбъект, "InventoryPO", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'InventoryPO' is empty!",
			ЭтотОбъект, "InventoryPO", , Отказ);
		КонецЕсли;
		
	КонецЕсли;	
    // } RGS AArsentev S-I-0001855 06.09.2016 23:38:52
	     		 	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////

Процедура ПроверитьAcceptedБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
			
	Если CustomUnionTransaction И НЕ ЗначениеЗаполнено(Incoterms) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Не заполнено поле 'Условия поставки'!",
			ЭтотОбъект, "Incoterms", , Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Incoterms' is empty!",
			ЭтотОбъект, "Incoterms", , Отказ);
		КонецЕсли;

	КонецЕсли;
		
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью()
	
	СтруктураТекстов = Новый Структура;
	СтруктураПараметров = Новый Структура;
	
	СтруктураПараметров.Вставить("Ссылка", Ссылка);
	
	Если НЕ ЭтоНовый() Тогда
		
		СтруктураТекстов.Вставить("СтарыеРеквизитыШапки",
			"ВЫБРАТЬ
			|	TransportRequests.Ссылка,
			|	TransportRequests.ПометкаУдаления,
			|	TransportRequests.Номер,
			|	TransportRequests.Дата,
			|	TransportRequests.Проведен,
			|	StagesOfTransportRequests.Stage,
			|	TransportRequests.Specialist,
			// { RGS AFokin 10.10.2018 23:59:59 - S-I-0006147
			|	TransportRequests.AcceptedBySpecialistLocalTime,
			// } RGS AFokin 10.10.2018 23:59:59 - S-I-0006147
			|	TransportRequests.Company
			|ИЗ
			|	Документ.TransportRequest КАК TransportRequests
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTransportRequests КАК StagesOfTransportRequests
			|		ПО TransportRequests.Ссылка = StagesOfTransportRequests.TransportRequest
			|ГДЕ
			|	TransportRequests.Ссылка = &Ссылка");
			     					
		СтруктураТекстов.Вставить("РеквизитыItems",
			"ВЫБРАТЬ
			|	Items.Ссылка КАК Item,
			|	Items.SoldTo,
			|	Items.Активити КАК Activity,
			|	Items.Количество КАК Qty,
			|	Items.ЕдиницаИзмерения,
			|	Items.NetWeight,
			|	Items.WeightUOM,
			|	СУММА(ParcelsItems.Qty) КАК QtyInParcels,
			|	СУММА(ParcelsItems.NetWeight) КАК NetWeightInParcels,
			|	Items.ПометкаУдаления,
			|	Items.TNVED,
			|	Items.Currency,
			|	Items.Цена,
			|	Items.СтранаПроисхождения,
			|	Items.ProjectMobilization,
			|	Items.КостЦентр КАК AU,
			|	Items.RAN
			|ИЗ
			|	Справочник.СтрокиИнвойса КАК Items
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsItems
			|		ПО Items.Ссылка = ParcelsItems.СтрокаИнвойса
			|			И (НЕ ParcelsItems.Ссылка.Отменен)
			|ГДЕ
			|	Items.TransportRequest = &Ссылка
			|	И НЕ Items.ПометкаУдаления
			|
			|СГРУППИРОВАТЬ ПО
			|	Items.Ссылка,
			|	Items.SoldTo,
			|	Items.Активити,
			|	Items.Количество,
			|	Items.ЕдиницаИзмерения,
			|	Items.NetWeight,
			|	Items.WeightUOM,
			|	Items.ПометкаУдаления,
			|	Items.TNVED,
			|	Items.Currency,
			|	Items.Цена,
			|	Items.СтранаПроисхождения,
			|	Items.ProjectMobilization,
			|	Items.КостЦентр");
			
		СтруктураТекстов.Вставить("РеквизитыParcels",
			"ВЫБРАТЬ
			|	Parcels.Ссылка КАК Parcel,
			|	Parcels.NumOfParcels,
			|	Parcels.ПометкаУдаления
			|ИЗ
			|	Справочник.Parcels КАК Parcels
			|ГДЕ
			|	Parcels.TransportRequest = &Ссылка
			|	И НЕ Parcels.ПометкаУдаления");	
			
		СтруктураТекстов.Вставить("РеквизитыParcelsLines",
			"ВЫБРАТЬ
			|	ParcelsДетали.Ссылка КАК Parcel,
			|	ParcelsДетали.NetWeight,
			|	ParcelsДетали.НомерСтроки
			|ИЗ
			|	Справочник.Parcels.Детали КАК ParcelsДетали
			|ГДЕ
			|	ParcelsДетали.Ссылка.TransportRequest = &Ссылка
			|	И НЕ ParcelsДетали.Ссылка.ПометкаУдаления");
			 				
	КонецЕсли;
	          			
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ВыборкаСтарыхРеквизитовШапки", Неопределено);
	Если СтруктураРезультатов.Свойство("СтарыеРеквизитыШапки") Тогда
		ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки = СтруктураРезультатов.СтарыеРеквизитыШапки.Выбрать(); 
		ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки.Следующий();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаItems", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыItems") Тогда
		ДополнительныеСвойства.ТаблицаItems = СтруктураРезультатов.РеквизитыItems.Выгрузить();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаParcels", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыParcels") Тогда
		ДополнительныеСвойства.ТаблицаParcels = СтруктураРезультатов.РеквизитыParcels.Выгрузить();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаParcelsLines", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыParcelsLines") Тогда
		ДополнительныеСвойства.ТаблицаParcelsLines = СтруктураРезультатов.РеквизитыParcelsLines.Выгрузить();
	КонецЕсли;
	 		        		
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////

Процедура ПроверитьВозможностьИзмененияСДополнительнымиДанными(Отказ)
	           		
	Если Не Проведен Тогда 
		Возврат;
	КонецЕсли;
	
	МассивParcels = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекции(ДополнительныеСвойства.ТаблицаParcelsLines, "Parcel");
	
	Отказ = Не Документы.TransportRequest.РазрешеноРедактироватьAcceptedTransportRequest(Ссылка, МассивParcels);
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда 
		Возврат;
	КонецЕсли;
	
	Если РежимЗаписи = РежимЗаписиДокумента.ОтменаПроведения Тогда 
		Возврат;
	КонецЕсли;
	
	Если (Не ЗначениеЗаполнено(RequestedLocalTime) 
		И РежимЗаписи <> РежимЗаписиДокумента.Проведение)
		// { RGS AArsentev 26.07.2018 Multimodal copy
		ИЛИ (ЗначениеЗаполнено(ParentTR) И РежимЗаписи <> РежимЗаписиДокумента.Проведение) Тогда
		// } RGS AArsentev 26.07.2018 Multimodal copy
		Возврат;
	КонецЕсли;

	ПроверитьItemsСДополнительнымиДанными(Отказ, ДополнительныеСвойства.ТаблицаItems);
		
	ПроверитьParcelsСДополнительнымиДанными(Отказ, ДополнительныеСвойства.ТаблицаParcels, ДополнительныеСвойства.ТаблицаParcelsLines);
				
КонецПроцедуры

Процедура ПроверитьItemsСДополнительнымиДанными(Отказ, ТаблицаItems)
	         		
	// Потребуем, чтобы был введен хотя бы один товар
	Если (ЭтоНовый() ИЛИ ТаблицаItems.Количество() = 0) Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Таблица Items (товаров) не заполнена!",
			ЭтотОбъект, "Items", "Объект", Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"List of Items is empty!",
			ЭтотОбъект, "Items", "Объект", Отказ);
		КонецЕсли;

		Возврат;
		
	КонецЕсли;
	
	Для Каждого СтрокаТаблицы Из ТаблицаItems Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.QtyInParcels) Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Товар '" + СокрЛП(СтрокаТаблицы.Item) + "' не принадлежит ни одному грузовому месту!",
				СтрокаТаблицы.Item,,, Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Item '" + СокрЛП(СтрокаТаблицы.Item) + "' does not belong to any parcel!",
				СтрокаТаблицы.Item,,, Отказ);
			КонецЕсли;
			
		Иначе
				
			Если СтрокаТаблицы.Qty <> СтрокаТаблицы.QtyInParcels Тогда	
				
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Количество " + Формат(СтрокаТаблицы.Qty, "ЧН=0") + " " + СокрЛП(СтрокаТаблицы.ЕдиницаИзмерения) + " товара '" + СокрЛП(СтрокаТаблицы.Item) + "' отличается от общего количества " + Формат(СтрокаТаблицы.QtyInParcels, "ЧН=0") + " в грузовых местах!",
					СтрокаТаблицы.Item,,, Отказ);	
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Qty " + Формат(СтрокаТаблицы.Qty, "ЧН=0") + " " + СокрЛП(СтрокаТаблицы.ЕдиницаИзмерения) + " of Item '" + СокрЛП(СтрокаТаблицы.Item) + "' differs from total qty " + Формат(СтрокаТаблицы.QtyInParcels, "ЧН=0") + " in parcels!",
					СтрокаТаблицы.Item,,, Отказ);	
				КонецЕсли;
				
			КонецЕсли;
	
			Если ЗначениеЗаполнено(СтрокаТаблицы.NetWeight) И СтрокаТаблицы.NetWeight <> СтрокаТаблицы.NetWeightInParcels Тогда	
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Вес нетто " + Формат(СтрокаТаблицы.NetWeight, "ЧН=0") + " " + СокрЛП(СтрокаТаблицы.WeightUOM) + " товара " + СокрЛП(СтрокаТаблицы.Item) + "' отличается от веса " + Формат(СтрокаТаблицы.NetWeightInParcels, "ЧН=0") + " в грузовых местах!",
					СтрокаТаблицы.Item,,, Отказ);	
				иначе
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Net weight " + Формат(СтрокаТаблицы.NetWeight, "ЧН=0") + " " + СокрЛП(СтрокаТаблицы.WeightUOM) + " of Item '" + СокрЛП(СтрокаТаблицы.Item) + "' differs from net weight " + Формат(СтрокаТаблицы.NetWeightInParcels, "ЧН=0") + " in parcels!",
					СтрокаТаблицы.Item,,, Отказ);	
				КонецЕсли;
			КонецЕсли;
				
		КонецЕсли;
		
		Если CustomUnionTransaction Тогда 
			
			Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.СтранаПроисхождения) Тогда		
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "Не заполнено поле 'Страна происхождения' товара " + СокрЛП(СтрокаТаблицы.Item) + "!";
				иначе
					ТекстОшибки = "'Country of origin' of Item '" + СокрЛП(СтрокаТаблицы.Item) + " is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					ТекстОшибки,
					СтрокаТаблицы.Item,, , Отказ);		
			КонецЕсли;

			Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.Цена) Тогда		
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "Не заполнено поле 'Цена за единицу' товара " + СокрЛП(СтрокаТаблицы.Item) + "!";
				иначе
					ТекстОшибки = "'Unit price' of Item '" + СокрЛП(СтрокаТаблицы.Item) + " is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					ТекстОшибки,
					СтрокаТаблицы.Item, , , Отказ);		
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.Currency) Тогда		
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "Не заполнено поле 'Валюта' товара " + СокрЛП(СтрокаТаблицы.Item) + "!";
				иначе
					ТекстОшибки = "'Currency' of Item '" + СокрЛП(СтрокаТаблицы.Item) + " is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					ТекстОшибки,
					СтрокаТаблицы.Item, , , Отказ);		
			КонецЕсли;

			Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.TNVED) Тогда		
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "Не заполнено поле 'ТНВЭД' товара " + СокрЛП(СтрокаТаблицы.Item) + "!";
				иначе
					ТекстОшибки = "'TNVED' of Item '" + СокрЛП(СтрокаТаблицы.Item) + " is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					ТекстОшибки,
					СтрокаТаблицы.Item, , , Отказ);		
			КонецЕсли;
			
			Если ExportPurpose = Справочники.ExportPurposes.RAN И НЕ ЗначениеЗаполнено(СтрокаТаблицы.RAN) Тогда
				Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
					ТекстОшибки = "Не заполнено поле 'Номер разрешения на возврат (RAN)' товара " + СокрЛП(СтрокаТаблицы.Item) + "!";
				иначе
					ТекстОшибки = "'RAN' of Item '" + СокрЛП(СтрокаТаблицы.Item) + " is empty!";
				КонецЕсли;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					ТекстОшибки,
					СтрокаТаблицы.Item, , , Отказ);		
			КонецЕсли;

		КонецЕсли;
		
	КонецЦикла;	
			
КонецПроцедуры

Процедура ПроверитьParcelsСДополнительнымиДанными(Отказ, ТаблицаParcels, ТаблицаParcelsLines)
	       		
	Если ЭтоНовый() ИЛИ ТаблицаParcels.Количество() = 0 Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Таблица Parecels (грузовых мест) не заполнена!",
			ЭтотОбъект, "Parcels",, Отказ);
		иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"List of Parcels is empty!",
			ЭтотОбъект, "Parcels", "Объект", Отказ);
		КонецЕсли;
				
	КонецЕсли;
		
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// ПРИ ЗАПИСИ

Процедура ПриЗаписи(Отказ)
	
	Если ДополнительныеСвойства.Свойство("ВыполнениеОбработки") Тогда 
		Возврат;
	КонецЕсли;
	
	// УДАЛИТЬ после переноса в TRIP выгрузки TMS
	УстановитьПривилегированныйРежим(Истина);
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("TransportRequest", Ссылка);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	TripNonLawsonCompaniesParcels.Ссылка КАК Trip
	               |ИЗ
	               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	               |ГДЕ
	               |	TripNonLawsonCompaniesParcels.Ссылка.Проведен
	               |	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TransportRequest";
				   
	Выборка = Запрос.Выполнить().Выбрать();
	пока Выборка.Следующий() Цикл 
		TripОбъект = Выборка.Trip.ПолучитьОбъект();
		TripОбъект.обменДанными.загрузка = Истина;
		TripОбъект.записать();
	КонецЦикла;	
	
	Если ДополнительныеСвойства.Свойство("ToTMS") Тогда 
		Возврат;
	КонецЕсли;
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	ЗаписыватьДокументБезДополнительныхПроверок = Ложь;
	CurrentStage = РегистрыСведений.StagesOfTransportRequests.ОпределитьStage(Ссылка);
	Если CurrentStage = Перечисления.TransportRequestStages.Requested И ReturnToRequestor Тогда
		ЗаписыватьДокументБезДополнительныхПроверок = Истина;
	КонецЕсли;	
	Если НЕ ЗаписыватьДокументБезДополнительныхПроверок Тогда
	// } RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	
	ОбновитьРеквизитыItems(Отказ, ДополнительныеСвойства.ТаблицаItems);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ОбновитьРеквизитыParcels(Отказ, ДополнительныеСвойства.ТаблицаParcels);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS AArsentev 28.09.2017 S-I-0003496
	//ПроверитьНаличиеУдаленныхАйтемов(Отказ);
	
	Если Отказ Тогда
		Возврат
	КонецЕсли;
	// } RGS AArsentev 28.09.2017 S-I-0003496
	
	// { RGS AArsentev 09.01.2018 S-I-0003708
	ПроверитьСоставПарселей(Отказ);
	
	Если Отказ Тогда
		Возврат
	КонецЕсли;
	// } RGS AArsentev 09.01.2018 S-I-0003708
	
	// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	КонецЕсли;	
	// } RGS AFokin 09.09.2018 23:59:59 S-I-0005813

	NewStage = РегистрыСведений.StagesOfTransportRequests.ПолучитьTransportRequestStage(Ссылка);
	
	// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	Если ReturnToRequestor Тогда
		Если НЕ ЗначениеЗаполнено(Comments) ИЛИ НЕ ЗначениеЗаполнено(ReasonForReturn) Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = НСтр("ru = 'При возврате заявки необходимо оставить комментарий и указать причину!'; 
			    				   |en = 'When returning request, you must leave a comment and specify the reason!'");
			Сообщение.Сообщить();
		Иначе
			NewStage = Перечисления.TransportRequestStages.Draft;
		КонецЕсли;	
	КонецЕсли;
	// } RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	
	ОбновитьStage(ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки, NewStage);
	
	ОтправитьУведомление(ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки, NewStage);
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ОбновитьРеквизитыItems(Отказ, ТаблицаItems)
	
	Если ТаблицаItems = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТаблицы Из ТаблицаItems Цикл
		
		Если СтрокаТаблицы.SoldTo <> Company
			ИЛИ СтрокаТаблицы.Activity <> Activity 
			ИЛИ СтрокаТаблицы.AU <> CostCenter
			ИЛИ СтрокаТаблицы.ProjectMobilization <> ProjectMobilization
			ИЛИ (ПометкаУдаления И Не СтрокаТаблицы.ПометкаУдаления) Тогда
			
			ItemОбъект = СтрокаТаблицы.Item.ПолучитьОбъект();
			ItemОбъект.ПометкаУдаления = ПометкаУдаления;
						
			Попытка
				ItemОбъект.Записать();
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Не удалось обновить данные ""Item / товар " + СокрЛП(ItemОбъект) + """!
					|" + ОписаниеОшибки(),
					ItemОбъект.Ссылка,,, Отказ);
				Возврат;
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ОбновитьРеквизитыParcels(Отказ, ТаблицаParcels)
	
	Если ТаблицаParcels = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТаблицы Из ТаблицаParcels Цикл
		
		Если ПометкаУдаления И Не СтрокаТаблицы.ПометкаУдаления Тогда
			
			ParcelОбъект = СтрокаТаблицы.Parcel.ПолучитьОбъект();
			ParcelОбъект.ПометкаУдаления = ПометкаУдаления;
			
			Попытка
				ParcelОбъект.Записать();
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Не удалось обновить ""Parcel / грузовое место " + СокрЛП(ParcelОбъект) + """! См. ошибки выше.",
					ЭтотОбъект,,, Отказ);
				Возврат;
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////

Процедура ОбновитьStage(ВыборкаСтарыхРеквизитовШапки, NewStage)
		
	Если ВыборкаСтарыхРеквизитовШапки <> Неопределено
		И ВыборкаСтарыхРеквизитовШапки.Stage = NewStage Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	МенеджерЗаписи = РегистрыСведений.StagesOfTransportRequests.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.TransportRequest = Ссылка;
	МенеджерЗаписи.Stage = NewStage;                          
	МенеджерЗаписи.ModificationDate = ТекущаяДата();
	МенеджерЗаписи.Записать(Истина);
	       		
КонецПроцедуры

Процедура ОтправитьУведомление(ВыборкаСтарыхРеквизитовШапки, NewStage)
	
	Если ВыборкаСтарыхРеквизитовШапки <> Неопределено
		И ВыборкаСтарыхРеквизитовШапки.Stage = NewStage 
		И ВыборкаСтарыхРеквизитовШапки.ПометкаУдаления = ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	//Если NewStage = Перечисления.TransportRequestStages.Draft Тогда
	Если NewStage = Перечисления.TransportRequestStages.Draft И НЕ ReturnToRequestor Тогда
	// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
		Возврат;
	КонецЕсли;
	
	// { RGS AArsentev 26.07.2018 Multimodal copy
	Если ВыборкаСтарыхРеквизитовШапки = Неопределено Тогда
		Возврат;
	КонецЕсли;
	// } RGS AArsentev 26.07.2018 Multimodal copy
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТекущийПользователь = ПараметрыСеанса.ТекущийПользователь;
	
	Если ПометкаУдаления И Не ВыборкаСтарыхРеквизитовШапки.ПометкаУдаления Тогда
		
		// отправим requester и specialist - исключаем текущего пользователя
		
		Тема = "Transport request / Заявка " + СокрЛП(Номер) + " была помечена на удаление / was marked for deletion";
		Тело = "Transport request / Заявка " + СокрЛП(Номер) + " была помечена на удаление / was marked for deletion by " + ПараметрыСеанса.ТекущийПользователь;
		
		МассивEmails = Новый Массив;
		Если Requestor <> ТекущийПользователь Тогда 
			МассивEmails.Добавить(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Requestor, "EMail"));
		КонецЕсли;
		Если Specialist <> ТекущийПользователь Тогда 
			МассивEmails.Добавить(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Specialist, "EMail"));
		КонецЕсли;
		       		
		Адрес = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивEmails, ";");
	
	КонецЕсли;
	
	Если NewStage = Перечисления.TransportRequestStages.Requested Тогда
		
		Если ВыборкаСтарыхРеквизитовШапки.Stage = Перечисления.TransportRequestStages.AcceptedBySpecialist Тогда
			
			// AcceptedBySpecialist было отменено - отправим requester
			Если Requestor = ТекущийПользователь Тогда 
				Возврат;
			КонецЕсли;
			
			ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Requestor, "Код"));
			
			Адрес = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Requestor, "EMail");
			
			Если ПользовательИБ <> Неопределено И ПользовательИБ.Язык = Метаданные.Языки.Русский Тогда 
				Тема = "Статус " + СокрЛП(Номер) + " место отправления '" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "NameRus")) + " был изменен на 'На согласовании'";
				Тело = "Статус заявки " + СокрЛП(Номер) + " место отправления '" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "NameRus")) + " был изменен на 'На согласовании': " + ПараметрыСеанса.ТекущийПользователь;
			Иначе 
				Тема = "Stage of " + СокрЛП(Номер) + " pick-up from " + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "Наименование")) + " was changed to 'Requested'";
				Тело = "Stage of transport request " + СокрЛП(Номер) + " pick-up from " + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "Наименование")) + " was changed to 'Requested' by " + ПараметрыСеанса.ТекущийПользователь;
			КонецЕсли;
			
		иначе
			     						
			Адрес = СокрЛП(Константы.АдресатыПолученияНовыхЗаявокНаДоставку.Получить());
			
			Тема = "Stage of " + СокрЛП(Номер) + " pick-up from '" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "Наименование")) + "' was changed to 'Requested'";
			Тело = "Stage of transport request " + СокрЛП(Номер) + " pick-up from '" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "Наименование")) + "' was changed to 'Requested' by " + ПараметрыСеанса.ТекущийПользователь;
			
			ОтправитьУведомлениеRequestor();  //S-I-0001945
			
		КонецЕсли;
		     				
	КонецЕсли;
	
	Если NewStage = Перечисления.TransportRequestStages.AcceptedBySpecialist Тогда
		
		// AcceptedBySpecialist - отправить requester
		Если Requestor = ТекущийПользователь Тогда 
			Возврат;
		КонецЕсли;
		
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Requestor, "Код")));

		Если ПользовательИБ <> Неопределено И ПользовательИБ.Язык = Метаданные.Языки.Русский Тогда 
			Тема = СокрЛП(Номер) + " место отправления '" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "NameRus")) + "' принята специалистом";
			Тело = "Заявка " + СокрЛП(Номер) + " место отправления '" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "NameRus")) + "' принята специалистом: " + ПараметрыСеанса.ТекущийПользователь;
		Иначе 
			Тема = СокрЛП(Номер) + " pick-up from '" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "Наименование")) + "' was changed to 'Accepted by specialist'";
			Тело = "Transport request " + СокрЛП(Номер) + " pick-up from '" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(PickUpWarehouse, "Наименование")) + "' was changed to 'Accepted by specialist' by " + ПараметрыСеанса.ТекущийПользователь;
		КонецЕсли;
		
		Адрес = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Requestor, "EMail");
		
	КонецЕсли;
	
	// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	Если NewStage = Перечисления.TransportRequestStages.Draft Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Requestor, "Код")));
		ПричинаВозвратаЗаявки = "";
		Если ПользовательИБ <> Неопределено И ПользовательИБ.Язык = Метаданные.Языки.Русский Тогда
			Если ReasonForReturn = Перечисления.ReasonForReturn.IncorrectCargoDetails Тогда
				ПричинаВозвратаЗаявки = "Некорректная информация по грузу (вес/размеры/количество мест)";
			ИначеЕсли ReasonForReturn = Перечисления.ReasonForReturn.IncorrectFinancialInformation Тогда
				ПричинаВозвратаЗаявки = "Некорректная финансовая информация (Плательщик/затратный центр/Активити)";
			ИначеЕсли ReasonForReturn = Перечисления.ReasonForReturn.UnrealisticDatesTimes Тогда
				ПричинаВозвратаЗаявки = "Нереалистичное время забора или доставки груза";
			ИначеЕсли ReasonForReturn = Перечисления.ReasonForReturn.IncorrectMissingIinformationOnLoadingUnloadingLocations Тогда
				ПричинаВозвратаЗаявки = "Некорректная/неполная информация о местах погрузки или выгрузки";
			ИначеЕсли ReasonForReturn = Перечисления.ReasonForReturn.Other Тогда
				ПричинаВозвратаЗаявки = "Другое";
			КонецЕсли;
			Тема = СокрЛП(Номер) + " Внимание!!! Исполнение заявки приостановлено. Требуется уточнение информации.";
			Тело = "<p>Причина возврата заявки - " + ПричинаВозвратаЗаявки + ". " + "Комментарий - " + Comments + ".</p> 
				   |
				   |<p>После внесения изменений в заявку, пожалуйста, нажмите кнопку «Запросить» на закладке «Согласование заявки».</p>
				   |
				   |<p>Спасибо.</p>";
		Иначе 
			Если ReasonForReturn = Перечисления.ReasonForReturn.IncorrectCargoDetails Тогда
				ПричинаВозвратаЗаявки = "Incorrect cargo details (weight/dimensions/number of packages)";
			ИначеЕсли ReasonForReturn = Перечисления.ReasonForReturn.IncorrectFinancialInformation Тогда
				ПричинаВозвратаЗаявки = "Incorrect financial information (Legal entity/Cost Center/AU)";
			ИначеЕсли ReasonForReturn = Перечисления.ReasonForReturn.UnrealisticDatesTimes Тогда
				ПричинаВозвратаЗаявки = "Unrealistic Dates&Times (Ready to ship time/Required Delivery time) ";
			ИначеЕсли ReasonForReturn = Перечисления.ReasonForReturn.IncorrectMissingIinformationOnLoadingUnloadingLocations Тогда
				ПричинаВозвратаЗаявки = "Incorrect missing iinformation on loading unloading locations";
			ИначеЕсли ReasonForReturn = Перечисления.ReasonForReturn.Other Тогда
				ПричинаВозвратаЗаявки = "Other";
			КонецЕсли;			
			Тема = СокрЛП(Номер) + " Attention!!! Transport Request processing is stopped. Additional information is required.";
			Тело = "<p>Reason for Transport Request Return - " + ПричинаВозвратаЗаявки + "." + Символы.ПС + "Comment - " + Comments + ".</p>
				   |
				   |<p>Please press «Request» button on «Reconсilation» tab after Transport request correction.</p>
				   |
				   |<p>Thank you.</p>";
		КонецЕсли;
		Адрес = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Requestor, "EMail");
		ОтправитьУведомлениеОВозвратеЗаявки(Тема, Тело, Адрес);
		Возврат;
	КонецЕсли;
	// } RGS AFokin 09.09.2018 23:59:59 S-I-0005813
	
	Тело = ДобавитьСсылкуНаTR(Тело);
	
	Если ЗначениеЗаполнено(Адрес) Тогда 
		РГСофт.ЗарегистрироватьПочтовоеСообщение(Адрес, Тема, Тело,,);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(NotificationRecipients) Тогда 
		РГСофт.ЗарегистрироватьПочтовоеСообщение(NotificationRecipients, Тема, Тело);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОтправитьУведомлениеRequestor()
	
	// Planner
	PlannerEmail = "";
	PlannerPhoneNumber = "";
	
	ВыборкаPlanner = ПолучитьВыборкуКонтактовПользователя(Specialist);
	Пока ВыборкаPlanner.Следующий() Цикл
		Если ВыборкаPlanner.Вид = Справочники.ВидыКонтактнойИнформации.ТелефонСлужебный Тогда 
			PlannerPhoneNumber = СокрЛП(ВыборкаPlanner.Представление);
		КонецЕсли;
		Если ВыборкаPlanner.Вид = Справочники.ВидыКонтактнойИнформации.EmailПользователя Тогда 
			PlannerEmail = СокрЛП(ВыборкаPlanner.Представление);
		КонецЕсли;
	КонецЦикла;   	    
	
	// Team Lead
	TeamLeadEmail = "";
	TeamLeadPhoneNumber = "";
	
	ВыборкаTeamLead = ПолучитьВыборкуКонтактовПользователя(Константы.PlannersTeamLead.Получить());
	Пока ВыборкаTeamLead.Следующий() Цикл
		Если ВыборкаTeamLead.Вид = Справочники.ВидыКонтактнойИнформации.ТелефонСлужебный Тогда 
			TeamLeadPhoneNumber = СокрЛП(ВыборкаTeamLead.Представление);
		КонецЕсли;
		Если ВыборкаTeamLead.Вид = Справочники.ВидыКонтактнойИнформации.EmailПользователя Тогда 
			TeamLeadEmail = СокрЛП(ВыборкаTeamLead.Представление);
		КонецЕсли;
	КонецЦикла;  
	
	Тема = "Transport request " + СокрЛП(Номер);
	
	Тело = "Dear " + СокрЛП(Requestor) + ",
	|
	|Thank you for your TR to Domestic Logistics Hub. Your TR accepted and will be update and/or proceed within 1 business days.
	|
	|For more details we may contact you in the nearest time. 
	| 
	|If you want to update your TR or in urgencies case follow up on progress of the status based on the following:
	|
	|- Reply to this email: " + PlannerEmail + ?(ЗначениеЗаполнено(PlannerPhoneNumber), " 
	|- Call to planner specialist: " + PlannerPhoneNumber, "") + "
	|
	|In case of the SQ possibility - please escalate it to team lead:  
	|- Е-mail: " + TeamLeadEmail + ?(ЗначениеЗаполнено(TeamLeadPhoneNumber), " 
	|- Phone number: " + TeamLeadPhoneNumber, "") + "
	|
	| 
	|Best Regards,
	|RCA Domestic Logistics Hub";
	
	ТелоHTML = "<HTML>
	|<TABLE border=1>
	|<TBODY>
	|<TR>
	|<TD style=""BACKGROUND-COLOR:#00008b"" align=""center""><FONT color=white>RCA Domestic Logistics HUB</FONT></TD>
	|<TD style=""BACKGROUND-COLOR:#00008b"" align=""center""><FONT color=white>RCA Центральный Логистический Центр</FONT< td> </FONT></TD>
	|<TR>
	|<TD>
	|<P>Dear " + СокрЛП(Requestor) + ", 
	|<P></P>
	|<P>Thank you for your TR to Domestic Logistics Hub. Your TR accepted and will be update and/or proceed within 1 business days.</P>
	|<P>For more details we may contact you in the nearest time.</P>
	|<P>If you want to update your TR or in urgencies case follow up on progress of the status based on the following:</P>
	|<P>- Reply to this email: " + PlannerEmail + ?(ЗначениеЗаполнено(PlannerPhoneNumber), ", </P>
	|<P>- Call to planner specialist: " + PlannerPhoneNumber, "") + "</P>
	|<P><U>In case of the SQ possibility - please escalate it to team lead:</U></P>
	|<P>- E-mail: " + TeamLeadEmail + ?(ЗначениеЗаполнено(TeamLeadPhoneNumber), " </P>
	|<P>- Phone number: " + TeamLeadPhoneNumber, "") +" </P>
	|<P>Best Regards,</P>
	|<P>RCA Domestic Logistics Hub</P><IMG src=v8config://v8cfgHelp/mdpicture/id3ecb51c8-562b-44f2-96dd-42471272e909></IMG> 
	|<P></P></TD>
	|<TD>
	|<P>Добрый день " + СокрЛП(Requestor) + ", 
	|<P></P>
	|<P>Спасибо за Ваше обращение в логистический центр. Ваш запрос на транспортировку принят и будет обновлен и обработан в течение 1 рабочего дня.</P>
	|<P>За более подробной информацией с Вами свяжутся в ближайшее время.</P>
	|<P>Если Вы хотите обновить информацию в запросе или в случае срочности запроса следуйте инструкциям:</P>
	|<P>- свяжитесь с планером по почте: " + PlannerEmail + ?(ЗначениеЗаполнено(PlannerPhoneNumber), ", </P>
	|<P>- позвоните планеру: " + PlannerPhoneNumber, "") + "</P>
	|<P><U>В случае вероятности SQ/критичности ситуации - пожалуйста сообщите лидеру команды:</U></P>
	|<P>- E-mail: " + TeamLeadEmail + ?(ЗначениеЗаполнено(TeamLeadPhoneNumber), " </P>
	|<P>- тел.: " + TeamLeadPhoneNumber, "") +" </P>
	|<P>С уважением,</P>
	|<P>Локальный логистический центр по России и Центральной Азии</P><IMG src=v8config://v8cfgHelp/mdpicture/id3ecb51c8-562b-44f2-96dd-42471272e909></IMG> 
	|<P></P></TD></TR></TBODY></TABLE>
	|<HTML>"; 
	
	Адрес = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Requestor, "EMail");
	РГСофт.ЗарегистрироватьПочтовоеСообщение(Адрес, Тема, ТелоHTML, , ТипТекстаПочтовогоСообщения.HTML, NotificationRecipients);
		           	       	
КонецПроцедуры

// { RGS AFokin 09.09.2018 23:59:59 S-I-0005813
Процедура ОтправитьУведомлениеОВозвратеЗаявки(Тема, Тело, Адрес)

	НавигационнаяСсылка = ПолучитьНавигационнуюСсылку(Ссылка);
	НавигационнаяСсылка = СтрЗаменить(НавигационнаяСсылка, """", "'");
	ПолнаяСсылка = "http://ru0149app35.dir.slb.com/RIET/#" + НавигационнаяСсылка;
	Тело = "<HTML> " + Тело + "
	|
	|<p>Link to the transport request / ссылка на заявку: " + ПолнаяСсылка + "</p>
	|<p>Link to the Local distribution tracking / Ссылка для контроля процесса доставки:http://ru0149app35.dir.slb.com/RIET</p><HTML>";

	РГСофт.ЗарегистрироватьПочтовоеСообщение(Адрес, Тема, Тело, , Перечисления.ТипыТекстовЭлектронныхПисем.HTML,);
		           	       	
КонецПроцедуры

// { RGS AFokin 10.10.2018 23:59:59 - S-I-0006147
Процедура ЗаполнитьГрафикиУведомленийПоСогласованнымTransportRequest()
	
	// запись для отправки уведомлений на 40 день согласованной заявки
	// для заявителя
	МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
	
	МенеджерЗаписи.TransportRequest = Ссылка;
	МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление40день;
	МенеджерЗаписи.ПолучательУведомленийTransportRequest = Перечисления.ПолучателиУведомленийTransportRequest.Заявитель;
	
	//МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (40 * 24*60*60);
	МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (60*60);
	
	МенеджерЗаписи.УведомлениеСоздано = Ложь;
	МенеджерЗаписи.УведомлениеОтправлено = Ложь;
	МенеджерЗаписи.ТрипСоздан = Ложь;
	
	МенеджерЗаписи.ГУИД = "";
	МенеджерЗаписи.Записать();
	
	// для логиста
	МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.TransportRequest = Ссылка;
	МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление40день;
	МенеджерЗаписи.ПолучательУведомленийTransportRequest = Перечисления.ПолучателиУведомленийTransportRequest.СпециалистОтделаЛогистики;
	
	//МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (40 * 24*60*60);
	МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (60*60);
	
	МенеджерЗаписи.УведомлениеСоздано = Ложь;
	МенеджерЗаписи.УведомлениеОтправлено = Ложь;
	МенеджерЗаписи.ТрипСоздан = Ложь;
	
	МенеджерЗаписи.ГУИД = "";
	МенеджерЗаписи.Записать();
	
	// для прочих получателей
	Если ЗначениеЗаполнено(NotificationRecipients) Тогда
		МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.TransportRequest = Ссылка;
		МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление40день;
		МенеджерЗаписи.ПолучательУведомленийTransportRequest = Перечисления.ПолучателиУведомленийTransportRequest.ПрочиеПолучатели;
		
		//МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (40 * 24*60*60);
		МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (60*60);
		
		МенеджерЗаписи.УведомлениеСоздано = Ложь;
		МенеджерЗаписи.УведомлениеОтправлено = Ложь;
		МенеджерЗаписи.ТрипСоздан = Ложь;
		
		МенеджерЗаписи.ГУИД = "";
		МенеджерЗаписи.Записать();
	КонецЕсли;
	
	// запись для отправки уведомлений на 45 день согласованной заявки
	// для заявителя
	МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.TransportRequest = Ссылка;
	МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление45день;
	МенеджерЗаписи.ПолучательУведомленийTransportRequest = Перечисления.ПолучателиУведомленийTransportRequest.Заявитель;
	
	//МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (45 * 24*60*60);
	МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (2*60*60);
	
	МенеджерЗаписи.УведомлениеСоздано = Ложь;
	МенеджерЗаписи.УведомлениеОтправлено = Ложь;
	МенеджерЗаписи.ТрипСоздан = Ложь;
	
	МенеджерЗаписи.ГУИД = "";
	МенеджерЗаписи.Записать();
	
	// для логиста
	МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.TransportRequest = Ссылка;
	МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление45день;
	МенеджерЗаписи.ПолучательУведомленийTransportRequest = Перечисления.ПолучателиУведомленийTransportRequest.СпециалистОтделаЛогистики;
	
	//МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (45 * 24*60*60);
	МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (2*60*60);
	
	МенеджерЗаписи.УведомлениеСоздано = Ложь;
	МенеджерЗаписи.УведомлениеОтправлено = Ложь;
	МенеджерЗаписи.ТрипСоздан = Ложь;
	
	МенеджерЗаписи.ГУИД = "";
	МенеджерЗаписи.Записать();
	
	// для прочих получателей
	Если ЗначениеЗаполнено(NotificationRecipients) Тогда
		МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.TransportRequest = Ссылка;
		МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление45день;
		МенеджерЗаписи.ПолучательУведомленийTransportRequest = Перечисления.ПолучателиУведомленийTransportRequest.ПрочиеПолучатели;
		
		//МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (45 * 24*60*60);
		МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (2*60*60);
		
		МенеджерЗаписи.УведомлениеСоздано = Ложь;
		МенеджерЗаписи.УведомлениеОтправлено = Ложь;
		МенеджерЗаписи.ТрипСоздан = Ложь;
		
		МенеджерЗаписи.ГУИД = "";
		МенеджерЗаписи.Записать();
	КонецЕсли;

	//// запись для отправки уведомлений на 40 день согласованной заявки
	//МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
	//МенеджерЗаписи.TransportRequest = Ссылка;
	//МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление40день;
	//МенеджерЗаписи.ПолучательУведомленийTransportRequest = Перечисления.ПолучателиУведомленийTransportRequest.ПустаяСсылка();
	//
	//МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (40 * 24*60*60);
	//МенеджерЗаписи.УведомлениеСоздано = Ложь;
	//МенеджерЗаписи.УведомлениеОтправлено = Ложь;
	//МенеджерЗаписи.ТрипСоздан = Ложь;
	//
	//МенеджерЗаписи.ГУИД = "";
	//МенеджерЗаписи.Записать();
	//
	//// запись для отправки уведомлений на 45 день согласованной заявки
	//МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
	//МенеджерЗаписи.TransportRequest = Ссылка;
	//МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление45день;
	//МенеджерЗаписи.ПолучательУведомленийTransportRequest = Перечисления.ПолучателиУведомленийTransportRequest.ПустаяСсылка();
	//
	//МенеджерЗаписи.ДатаОтправки = AcceptedBySpecialistLocalTime + (45 * 24*60*60);
	//МенеджерЗаписи.УведомлениеСоздано = Ложь;
	//МенеджерЗаписи.УведомлениеОтправлено = Ложь;
	//МенеджерЗаписи.ТрипСоздан = Ложь;
	//
	//МенеджерЗаписи.ГУИД = "";
	//МенеджерЗаписи.Записать();
	
КонецПроцедуры	

Функция ПолучитьВыборкуКонтактовПользователя(User)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("User", User);
	
	Запрос.Текст = "ВЫБРАТЬ
	|	ПользователиКонтактнаяИнформация.Вид,
	|	ПользователиКонтактнаяИнформация.Представление
	|ИЗ
	|	Справочник.Пользователи.КонтактнаяИнформация КАК ПользователиКонтактнаяИнформация
	|ГДЕ
	|	ПользователиКонтактнаяИнформация.Ссылка = &User
	|	И (ПользователиКонтактнаяИнформация.Вид = ЗНАЧЕНИЕ(Справочник.ВидыКонтактнойИнформации.ТелефонСлужебный)
	|			ИЛИ ПользователиКонтактнаяИнформация.Вид = ЗНАЧЕНИЕ(Справочник.ВидыКонтактнойИнформации.EmailПользователя))";
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

/////////////////////////////////////////////////////////////////////////
// ПРОВЕДЕНИЕ

Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр ParcelsOfTransportRequestsWithoutShipment Приход
	
	Движения.ParcelsOfTransportRequestsWithoutShipment.Записывать = Истина;
	Движения.ParcelsOfTransportRequestsWithoutShipment.Очистить();
	
	ТаблицаParcels = ДополнительныеСвойства.ТаблицаParcels;
	
	Для Каждого СтрокаParcel из ТаблицаParcels Цикл 	
		
		Движение = Движения.ParcelsOfTransportRequestsWithoutShipment.ДобавитьПриход();
		Движение.Период = Дата;
		Движение.Parcel = СтрокаParcel.Parcel;
		Движение.TransportRequest = Ссылка;
		Движение.NumOfParcels = СтрокаParcel.NumOfParcels;
		
	КонецЦикла;
	
	// { RGS AFokin 10.10.2018 23:59:59 - S-I-0006147
	Если ЭтоНовый() Тогда
		ЗаполнитьГрафикиУведомленийПоСогласованнымTransportRequest();	
	Иначе
		Если ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки.AcceptedBySpecialistLocalTime <> AcceptedBySpecialistLocalTime Тогда
			ЗаполнитьГрафикиУведомленийПоСогласованнымTransportRequest();
		КонецЕсли;	
	КонецЕсли;		
	// } RGS AFokin 10.10.2018 23:59:59 - S-I-0006147

КонецПроцедуры

Функция ДобавитьСсылкуНаTR(Текст)
	 	 
	НавигационнаяСсылка = ПолучитьНавигационнуюСсылку(Ссылка);
	НавигационнаяСсылка = СтрЗаменить(НавигационнаяСсылка, """", "'");
	ПолнаяСсылка = "http://ru0149app35.dir.slb.com/RIET/#" + НавигационнаяСсылка;
	HTMLСсылка = "<a href=""" + ПолнаяСсылка + """>" + ПолнаяСсылка + "</a>";
	Текст = Текст + "<br>
		|
		|Link to the transport request / ссылка на заявку: " + HTMLСсылка;
	
	ПолнаяСсылка = "http://ru0149app35.dir.slb.com/RIET";
	HTMLСсылка = "<a href=""" + ПолнаяСсылка + """>" + ПолнаяСсылка + "</a>";
	Возврат Текст + "<br>
		|
		|
		|Link to the Local distribution tracking / Ссылка для контроля процесса доставки: " + HTMLСсылка;
		
КонецФункции 

// { RGS AArsentev 28.09.2017 S-I-0003496
Процедура ПроверитьНаличиеУдаленныхАйтемов(Отказ)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ParcelsДетали.Ссылка КАК Parcel,
	|	ParcelsДетали.СтрокаИнвойса КАК Item
	|ИЗ
	|	Справочник.Parcels.Детали КАК ParcelsДетали
	|ГДЕ
	|	ParcelsДетали.СтрокаИнвойса.ПометкаУдаления
	|	И НЕ ParcelsДетали.Ссылка.ПометкаУдаления
	|	И ParcelsДетали.Ссылка.TransportRequest = &TransportRequest";
	Запрос.УстановитьПараметр("TransportRequest", Ссылка);
	ItemsНаУдаление = Запрос.Выполнить().Выгрузить();
	
	Для Каждого СтрItem из ItemsНаУдаление Цикл
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ТекстОшибки = "Товар "+СокрЛП(СтрItem.Item)+" грузового места "+СокрЛП(СтрItem.Parcel)+" помечен на удаление!";
		Иначе 	
			ТекстОшибки = "Item "+СокрЛП(СтрItem.Item)+" of parcel "+СокрЛП(СтрItem.Parcel)+" is marked for deletion!";
		КонецЕсли;
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки,
		ЭтотОбъект, "Parcels");
		
	КонецЦикла;
	
КонецПроцедуры // } RGS AArsentev 28.09.2017 S-I-0003496

// { RGS AArsentev 09.01.2018 S-I-0003708
Процедура ПроверитьСоставПарселей(Отказ)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Parcels.Ссылка КАК Парсель,
	|	КОЛИЧЕСТВО(Items.СтрокаИнвойса) КАК КоличествоАйтемов
	|ИЗ
	|	Справочник.Parcels КАК Parcels
	|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|			ParcelsДетали.Ссылка КАК Ссылка,
	|			ParcelsДетали.СтрокаИнвойса КАК СтрокаИнвойса
	|		ИЗ
	|			Справочник.Parcels.Детали КАК ParcelsДетали
	|		ГДЕ
	|			ParcelsДетали.СтрокаИнвойса.TransportRequest = &TransportRequest
	|			И НЕ ParcelsДетали.СтрокаИнвойса.ПометкаУдаления) КАК Items
	|		ПО Parcels.Ссылка = Items.Ссылка
	|ГДЕ
	|	Parcels.TransportRequest = &TransportRequest
	|	И НЕ Parcels.ПометкаУдаления
	|
	|СГРУППИРОВАТЬ ПО
	|	Parcels.Ссылка";
	Запрос.УстановитьПараметр("TransportRequest", Ссылка);
	АйтемыПоПарселям = Запрос.Выполнить().Выгрузить();
	
	ТекстОшибки = "";
	
	Для Каждого Parcel из АйтемыПоПарселям Цикл
		
		Если Не ЗначениеЗаполнено(Parcel.КоличествоАйтемов) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("В заявке нет товаров, соответствующих грузовому месту " + СокрЛП(Parcel.Парсель) + " !",
			ЭтотОбъект, "Parcels", ,Отказ);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры // } RGS AArsentev 28.09.2017 S-I-0003708

// { RGS AArsentev 31.07.2018
Процедура ПроверитьСпециалиста(Отказ);
	
	ЗапросAU = Новый Запрос;
	ЗапросAU.Текст = "ВЫБРАТЬ
	|	AU_Planners.AU КАК AU
	|ИЗ
	|	РегистрСведений.AU_Planners КАК AU_Planners
	|ГДЕ
	|	AU_Planners.AU = &AU";
	ЗапросAU.УстановитьПараметр("AU", CostCenter);
	
	РезультатAU = ЗапросAU.Выполнить();
	
	Если НЕ РезультатAU.Пустой() Тогда 
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	AU_Planners.AU,
		|	AU_Planners.Planner
		|ИЗ
		|	РегистрСведений.AU_Planners КАК AU_Planners
		|ГДЕ
		|	AU_Planners.AU = &AU
		|	И AU_Planners.Planner = &Planner";
		Запрос.УстановитьПараметр("AU", CostCenter);
		Запрос.УстановитьПараметр("Planner", Specialist);
		Результат = Запрос.Выполнить();
		Если Результат.Пустой() Тогда
			
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Специалист выбран некорректно, пожалуйста, выберите из выпадающего списка в поле 'Специалист' на закладке 'Согласование Заявки'",
				ЭтотОбъект, "Specialist", , Отказ);
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Specialist' does not match 'Cost center', please select Logistics Specialist from the drop down list in 'Reconciliation process' tab",
				ЭтотОбъект, "Specialist", , Отказ);
			КонецЕсли;
			
			Отказ = Истина;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры // } RGS AArsentev 31.07.2018

// { RGS AFokin 01.10.2018 23:59:59 - S-I-0006099
Процедура ПроверитьСоответствиеRCACoutryДля_ParentCompany_PickUpWarehouse_DeliverTo(Отказ)
	
	Если ЗначениеЗаполнено(Company.Country) И ЗначениеЗаполнено(PickUpWarehouse) Тогда
		Если Company.Country <> PickUpWarehouse.RCACountry Тогда
			Отказ = Истина;
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Страны отличаются в 'Место отправления' и 'Код компании'!", , "Company", "Объект");
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Countries differ in 'Pick-up From' and 'Company code'!", , "Company", "Объект");
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Company.Country) И ЗначениеЗаполнено(DeliverTo) Тогда
		Если Company.Country <> DeliverTo.RCACountry Тогда
			Отказ = Истина;
			Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Страны отличаются в 'Место доставки' и 'Код компании'!", , "Company", "Объект");
			иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Countries differ in 'Deliver-to' and 'Company code'!", , "Company", "Объект");
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры	

/////////////////////////////////////////////////////////////////////////
// ЛОГИРОВАНИЕ

Процедура ЗарегистрироватьИзменения(Отказ, ВыборкаСтарыхРеквизитовШапки)

	Если ЭтоНовый() Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТекстИзменений = "";
	
	МетаданныеОбъекта = Метаданные();
	СтрокаИсключаемыхРеквизитов =  
	"Country, Company, LegalEntity, Segment, ProductLine, Activity, ExternalReference, Urgency, RequiredDeliveryLocalTime, RequiredDeliveryUniversalTime, ReadyToShipLocalTime,
	| ReadyToShipUniversalTime, PickUpWarehouse, PickUpFromAddress, PickUpFromContact, PickUpFromPhone, PickUpFromEmail, DeliverToCountry, ConsignTo, DeliverTo, DeliverToAddress,
	| DeliverToContact, DeliverToPhone, DeliverToEmail, RequestedLocalTime, RequestedUniversalTime, Requestor, AcceptedBySpecialistLocalTime, AcceptedBySpecialistUniversalTime,
	| Specialist, Comments, DualUse, Recharge, RechargeDetails, CreatedBy, CreationDate, ModifiedBy, ModificationDate, TotalNumOfParcels, Loading, AgreementForRecharge, AcquisitionCost,
	| CostCenter, RechargeToLegalEntity, RechargeToAU, RechargeToActivity, PayingEntity, TMSOBNumber, SentToTMS, SegmentLawson, ActivityLawson, CustomUnionTransaction, Incoterms,
	| NotificationRecipients, ExportRequest, RechargeType, Milage, Sum, ProjectClient, ProjectMobilization, InventoryPO, Regime, ClientForRecharge, Shipper, ExportPurpose, ExportPurposeDescription,
	| LoadingEquipment, LoadingSlinger, UnloadingEquipment, UnloadingSlinger, AgreementNumber, AgreementDate, SpecificationNumber, SpecificationDate, PeriodOfTemporaryExport,
	| SH, SentCUReport, CUReportWasSent, DGFAU, ParentTR, ReadyToShipLocalTime";

	ТекстИзмененийШапки = ImportExportСервер.ПолучитьТекстИзмененияШапки(ЭтотОбъект,ВыборкаСтарыхРеквизитовШапки,Новый Массив,МетаданныеОбъекта.Реквизиты,СтрокаИсключаемыхРеквизитов);
	ТекстИзменений = ImportExportСервер.ДобавитьВТекстИзмененийБлок(ТекстИзменений, ТекстИзмененийШапки);	
	
	Если ТекстИзменений = "" Тогда
		Возврат;
	КонецЕсли;
	
	МенеджерЗаписи = РегистрыСведений.TransportRequestLogs.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.LogTo = Ссылка;
	МенеджерЗаписи.Date	= ТекущаяДата();
	МенеджерЗаписи.LogType	= Справочники.LogTypes.ИзменениеРеквизитов;
	МенеджерЗаписи.User	= ПараметрыСеанса.ТекущийПользователь;
	МенеджерЗаписи.Text	= ТекстИзменений;
	МенеджерЗаписи.Записать();
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

// { RGS AFokin 10.10.2018 23:59:59 - S-I-0006147
Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОчиститьГрафикиУведомленийПоСогласованнымTransportRequest();	
	
КонецПроцедуры

Процедура ОчиститьГрафикиУведомленийПоСогласованнымTransportRequest()
	
	// запись для отправки уведомлений на 40 день согласованной заявки
	МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.TransportRequest = Ссылка;
	МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление40день;
	МенеджерЗаписи.Прочитать();
	МенеджерЗаписи.Удалить();
	// запись для отправки уведомлений на 45 день согласованной заявки
	МенеджерЗаписи = РегистрыСведений.ГрафикиУведомленийTransportRequest.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.TransportRequest = Ссылка;
	МенеджерЗаписи.ТипУведомления = Перечисления.ТипыУведомленийTransportRequest.Уведомление45день;
	МенеджерЗаписи.Прочитать();
	МенеджерЗаписи.Удалить();
	
КонецПроцедуры	


	

СамаяРанняяДата = '20150101';

// { RG-Soft LGoncharova 06.12.2018 S-I-0006255
ДополнительныеСвойства.Вставить("ДатаВключенияReasonsForTR", '20181201');
// } RG-Soft LGoncharova 06.12.2018 S-I-0006255