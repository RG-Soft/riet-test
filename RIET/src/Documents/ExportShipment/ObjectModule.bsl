
/////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ТипЗнчДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения);
	Если ТипЗнчДанныхЗаполнения = Тип("ДокументСсылка.ExportRequest") Тогда
		ЗаполнитьПоExportRequest(ДанныеЗаполнения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПоExportRequest(ExportRequest)
	
	НоваяСтрокаТЧ = ExportRequests.Добавить();
	НоваяСтрокаТЧ.ExportRequest = ExportRequest;
	// { RGS AArsentev 23.08.2016 15:28:45 - S-I-0001816
	ProcessLevel = ExportRequest.ProcessLevel;
	// } RGS AArsentev 23.08.2016 15:28:45 - S-I-0001816
	// Остальные реквизиты заполнятся при открытии формы
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// ПРИ КОПИРОВАНИИ

Процедура ПриКопировании(ОбъектКопирования)
	
	// Очистим некоторые реквизиты
	
	SubmittedToCustoms = Неопределено;
	ReleasedFromCustoms = Неопределено;
	
	InternationalETD = Неопределено;
	InternationalATD = Неопределено;
	PreAlertSent = Неопределено;
	InternationalETA = Неопределено;
	InternationalATA = Неопределено;
	
	CreatedBy = Неопределено;
	CreationDate = Неопределено;
	ModifiedBy = Неопределено;
	ModificationDate = Неопределено;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// ПРИ УСТАНОВКЕ НОВОГО НОМЕРА

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	Префикс = "ESHIP";
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью();	
	
	ДозаполнитьРеквизитыСДополнительнымиДанными(ДополнительныеСвойства.ТаблицаExportRequests);
	
	ПроверитьВозможностьИзменения(Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли; 
	
	ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи);	
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Если НЕ ЗначениеЗаполнено(ExportSpecialist) Тогда
		ExportSpecialist = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	
	Если ЭтоНовый() Тогда
		Дата = ТекущаяДата();
		CreatedBy = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	           	
	Если НЕ ЗначениеЗаполнено(ModificationDate) Тогда
		ModificationDate = ТекущаяДата();
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(ModifiedBy) Тогда
		ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	 		
	CCDNumber = СокрЛП(CCDNumber);
	
	InternationalWB1 = СокрЛП(InternationalWB1);
	InternationalWB2 = СокрЛП(InternationalWB2);
	InternationalWB3 = СокрЛП(InternationalWB3);
	InternationalWB4 = СокрЛП(InternationalWB4);
	
	InternationalWBList = "";
	Если ЗначениеЗаполнено(InternationalWB1) Тогда
		InternationalWBList = InternationalWBList + ", " + InternationalWB1;
	КонецЕсли;
	Если ЗначениеЗаполнено(InternationalWB2) Тогда
		InternationalWBList = InternationalWBList + ", " + InternationalWB2;
	КонецЕсли;
	Если ЗначениеЗаполнено(InternationalWB3) Тогда
		InternationalWBList = InternationalWBList + ", " + InternationalWB3;
	КонецЕсли;
	Если ЗначениеЗаполнено(InternationalWB4) Тогда
		InternationalWBList = InternationalWBList + ", " + InternationalWB4;
	КонецЕсли;
	Если ЗначениеЗаполнено(InternationalWBList) Тогда
		InternationalWBList = Сред(InternationalWBList, 3);
	КонецЕсли;
	
	MoveITCRNo = СокрЛП(MoveITCRNo);
	
	CurrentComments = СокрЛП(CurrentComments);
	
	Если ExportRequests.Количество() > 0 Тогда
		ExportRequests.Свернуть("ExportRequest", "");
		ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(ExportRequests, "ExportRequest");
	КонецЕсли;
	
	// ТЧ OOC
	ИндексСтроки = 0;
	Пока ИндексСтроки < OutOfComplianceReasons.Количество() Цикл
		Если ЗначениеЗаполнено(OutOfComplianceReasons[ИндексСтроки].OutOfComplianceReason) Тогда
			ИндексСтроки = ИндексСтроки + 1;
		Иначе
			OutOfComplianceReasons.Удалить(ИндексСтроки);
		КонецЕсли;
	КонецЦикла;
	
	OOC = OutOfComplianceReasons.Количество() <> 0;

	Если CustomUnionTransaction Тогда
		
		SubmittedToCustoms = Неопределено;
		ReleasedFromCustoms = Неопределено;
	    CCA = Неопределено;
		CCDNumber = Неопределено;

	КонецЕсли;
	
	TMSShipmentID = СокрЛП(TMSShipmentID);
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	// Должен быть указан хотя бы один Export request
	Если ExportRequests.Количество() = 0 Тогда
		
		ТекстОшибок = "List of ""Export requests"" is empty!";
		ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
		ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ТекстОшибок,
			ЭтотОбъект, "ExportRequests", , Отказ);
		Возврат;
		
	КонецЕсли;
	
	// Submitted to customs
	Если ЗначениеЗаполнено(SubmittedToCustoms) Тогда
				
		Если SubmittedToCustoms > ТекущаяДата() Тогда
			 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Submitted to customs' can not be later than the current date!",
				ЭтотОбъект, "SubmittedToCustoms", , Отказ);
		КонецЕсли;
		
		Если ProcessLevel.Country = Справочники.CountriesOfProcessLevels.RU И Не ЗначениеЗаполнено(InternationalATA) Тогда 
			
			Если Не ЗначениеЗаполнено(ExportConfirmationRequested) Тогда
				 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Non-critical error: Please fill in 'Export confirmation date'.",
					ЭтотОбъект, //"ExportConfirmationRequested"
					, , );
			КонецЕсли;
				
		КонецЕсли;
	
	КонецЕсли;
	
	// Released from customs
	Если ЗначениеЗаполнено(ReleasedFromCustoms) Тогда 
		
		Если Не ЗначениеЗаполнено(SubmittedToCustoms) Тогда
			
			ТекстОшибок = "'Submitted to customs' is empty!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "SubmittedToCustoms", , Отказ);
				
		ИначеЕсли ReleasedFromCustoms < SubmittedToCustoms Тогда
				
			 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Released from customs' can not be earlier than 'Submitted to customs'!",
				ЭтотОбъект, "ReleasedFromCustoms", , Отказ);
				
		ИначеЕсли ReleasedFromCustoms > ТекущаяДата() Тогда
				
			 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Released from customs' can't be later than the current date!",
				ЭтотОбъект, "ReleasedFromCustoms", , Отказ);
				
		КонецЕсли;
		
	КонецЕсли;
	
	// International ATD
	Если ЗначениеЗаполнено(InternationalATD) Тогда 
		
		Если Не CustomUnionTransaction И НЕ ЗначениеЗаполнено(ReleasedFromCustoms) Тогда
			
			ТекстОшибок = """Released from customs"" is empty!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "ReleasedFromCustoms", , Отказ);
				
		ИначеЕсли Не CustomUnionTransaction И InternationalATD < ReleasedFromCustoms Тогда
				
			ТекстОшибок = """Int. ATD"" can not be earlier than ""Released from Customs""!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalATD", , Отказ);
				
		ИначеЕсли InternationalATD > ТекущаяДата() Тогда
				
			ТекстОшибок = """Int. ATD"" can't be later than the current date!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalATD", , Отказ);
				
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(InternationalWB1) Тогда
			
			ТекстОшибок = """Int. WB1"" is empty!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalWB1", , Отказ);
				
		КонецЕсли;	
		
		Если НЕ ЗначениеЗаполнено(InternationalETA) Тогда
			
			ТекстОшибок = """Int. ETA"" is empty!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalETA", , Отказ);
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Pre alert sent
	Если ЗначениеЗаполнено(PreAlertSent) Тогда
		
		Если Не CustomUnionTransaction И PreAlertSent < ReleasedFromCustoms Тогда
			
			ТекстОшибок = """Pre alert sent"" can not be earlier than ""Released from Customs""!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "PreAlertSent", , Отказ);
				
		ИначеЕсли PreAlertSent > ТекущаяДата() Тогда
				
			ТекстОшибок = """Pre alert sent"" can't be later than the current date!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "PreAlertSent", , Отказ);
				
		КонецЕсли;
		
	КонецЕсли;
	
	// International ETA
	Если ЗначениеЗаполнено(InternationalETA) Тогда
		
		Если НЕ ЗначениеЗаполнено(InternationalETD) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Int. ETD"" is empty!
				|You can not plan international arrival before you plan international departure",
				ЭтотОбъект, "InternationalETD", , Отказ);
			
		ИначеЕсли InternationalETA < InternationalETD Тогда
			
			ТекстОшибок = """Int. ETA"" can not be earlier than ""Int. ETD""!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalETA", , Отказ);
				
		КонецЕсли;
		
	КонецЕсли;
	
	// International ATA
	Если ЗначениеЗаполнено(InternationalATA) Тогда

		Если ProcessLevel.Country = Справочники.CountriesOfProcessLevels.RU И SubmittedToCustoms > Дата('20170101') Тогда 
			
			Если Не ЗначениеЗаполнено(ExportConfirmationRequested) Тогда
				 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Non-critical error: Please fill in 'Export confirmation requested'.",
					ЭтотОбъект, //"ExportConfirmationRequested"
					, , );
			КонецЕсли;
				
			Если Не ЗначениеЗаполнено(ExportConfirmationReceived) Тогда
				 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Non-critical error: Please fill in 'Export confirmation received'.",
					ЭтотОбъект, //"ExportConfirmationReceived"
					, , );
			КонецЕсли;
				
			Если Не ЗначениеЗаполнено(ExportConfirmationNo) Тогда
				 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Non-critical error: Please fill in 'Export confirmation no.'",
					ЭтотОбъект, //"ExportConfirmationNo"
					, , );
			КонецЕсли;

		КонецЕсли;

		Если Не ЗначениеЗаполнено(InternationalATD) Тогда
			
			ТекстОшибок = """Int. ATD"" is empty!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalATD", , Отказ);
			
		ИначеЕсли InternationalATA < InternationalATD Тогда
				
			ТекстОшибок = """Int. ATA"" can not be earlier than ""Int. ATD""!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalATA", , Отказ);
				
		ИначеЕсли InternationalATA > ТекущаяДата() Тогда
				
			ТекстОшибок = """Int. ATA"" can not be later than the current date!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalATA", , Отказ);
				
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(PreAlertSent) Тогда
			ТекстОшибок = """Pre alert sent"" is empty!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "PreAlertSent", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	// Notice of delivery date
	Если ЗначениеЗаполнено(NoticeOfDeliveryDate) Тогда 
		
		Если Не ЗначениеЗаполнено(InternationalATA)
			ИЛИ NoticeOfDeliveryDate < InternationalATA Тогда
		
			ТекстОшибок = """Notice of delivery date"" can not be earlier than ""Int. ATA""!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "NoticeOfDeliveryDate", , Отказ);
				
		КонецЕсли;
	
	КонецЕсли;
	    			
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью()
	
	СтруктураТекстов = Новый Структура;
	СтруктураПараметров = Новый Структура;
	
	СтруктураПараметров.Вставить("Ссылка", Ссылка);
	СтруктураПараметров.Вставить("ExportRequests", ExportRequests.ВыгрузитьКолонку("ExportRequest"));
	
	Если ExportRequests.Количество() Тогда
		
		СтруктураТекстов.Вставить("РеквизитыExportRequests",
			"ВЫБРАТЬ
			|	ExportRequests.Ссылка КАК ExportRequest,
			|	ExportRequests.Номер,
			|	ExportRequests.Company КАК ParentCompany,
			|	ExportRequests.InternationalOBSentToTMS,
			|	ExportRequests.ReadyToShipDate,
			|	ExportRequests.Submitted,
			|	ExportRequests.AcceptedBySpecialist,			
			|	ExportRequests.LocalFreightSubmittedForApproval,			
			|	ExportRequests.LocalATD,
			|	ExportRequests.LocalATA,
			|	ExportRequests.CCAGLRequested,
			|	ExportRequests.CCAGLReceived,
			|	ExportRequests.CCA,
			|	ExportRequests.PermitsRequired,
			|	ExportRequests.FumigationRequired,
			|	ExportRequests.PermitsObtained,
			// { RGS DKazanskiy 09.10.2018 12:51:58 - S-I-0005759	
			//
			//|	ExportRequests.LocalFreightApproved,
			//|	ExportRequests.LocalFreightReceived,
			//|	ExportRequests.FumigationCertificateRequired,
			//|	ExportRequests.FumigationDone,
			// } RGS DKazanskiy 09.10.2018 12:52:08 - S-I-0005759
			|	ExportRequests.ConsigneeGLRequested,
			|	ExportRequests.ConsigneeGLReceived,
			|	ExportRequests.InternationalFreightReceived,
			|	ExportRequests.InternationalFreightSubmittedForApproval,
			|	ExportRequests.InternationalFreightApproved,
			|	ExportRequests.InternationalFreightProvider,
			|	ExportRequests.POD,
			|	ExportRequests.POA,
			|	ExportRequests.InternationalMOT,
			|	ExportRequests.Canceled,
			|	StagesOfExportRequests.Stage,
			|	ExportRequests.Incoterms,
			|	ExportRequests.BORG,
			|	ExportRequests.CustomUnionTransaction,
			|	ExportRequests.FromCountry,
			|	ExportRequests.CreationDate
			|ИЗ
			|	Документ.ExportRequest КАК ExportRequests
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfExportRequests КАК StagesOfExportRequests
			|		ПО ExportRequests.Ссылка = StagesOfExportRequests.ExportRequest
			|ГДЕ
			|	ExportRequests.Ссылка В(&ExportRequests)");
			
		Если НЕ ПометкаУдаления Тогда
			
			СтруктураТекстов.Вставить("ExportRequestsВПохожихДокументах",
				"ВЫБРАТЬ
				|	ExportShipmentExportRequests.Ссылка.Представление КАК Представление,
				|	ExportShipmentExportRequests.ExportRequest
				|ИЗ
				|	Документ.ExportShipment.ExportRequests КАК ExportShipmentExportRequests
				|ГДЕ
				|	ExportShipmentExportRequests.Ссылка <> &Ссылка
				|	И (НЕ ExportShipmentExportRequests.Ссылка.ПометкаУдаления)
				|	И ExportShipmentExportRequests.ExportRequest В(&ExportRequests)");
			
		КонецЕсли;	
		          		
	КонецЕсли;

	Если Не ЭтоНовый() Тогда
		
		СтруктураТекстов.Вставить("РеквизитыУдаленныхExportRequests",
			"ВЫБРАТЬ
			|	ExportShipmentExportRequests.ExportRequest КАК ExportRequest,
			|	ExportShipmentExportRequests.ExportRequest.ReadyToShipDate КАК ReadyToShipDate,
			|	ExportShipmentExportRequests.ExportRequest.Submitted КАК Submitted,
			|	ExportShipmentExportRequests.ExportRequest.AcceptedBySpecialist КАК AcceptedBySpecialist,			
			|	ExportShipmentExportRequests.ExportRequest.LocalFreightSubmittedForApproval КАК LocalFreightSubmittedForApproval,			
			|	ExportShipmentExportRequests.ExportRequest.LocalATD КАК LocalATD,
			|	ExportShipmentExportRequests.ExportRequest.LocalATA КАК LocalATA,
			|	ExportShipmentExportRequests.ExportRequest.CCAGLRequested КАК CCAGLRequested,
			|	ExportShipmentExportRequests.ExportRequest.CCAGLReceived КАК CCAGLReceived,
			|	ExportShipmentExportRequests.ExportRequest.PermitsRequired КАК PermitsRequired,			
			|	ExportShipmentExportRequests.ExportRequest.FumigationRequired КАК FumigationRequired,	
			|	ExportShipmentExportRequests.ExportRequest.PermitsObtained КАК PermitsObtained,
			// { RGS DKazanskiy 09.10.2018 12:53:07 - S-I-0005759
			//
			//|	ExportShipmentExportRequests.ExportRequest.FumigationCertificateRequired КАК FumigationCertificateRequired,
			//|	ExportShipmentExportRequests.ExportRequest.FumigationDone КАК FumigationDone,
			//|	ExportShipmentExportRequests.ExportRequest.LocalFreightApproved КАК LocalFreightApproved,
			//|	ExportShipmentExportRequests.ExportRequest.LocalFreightReceived КАК LocalFreightReceived,
			// } RGS DKazanskiy 09.10.2018 12:53:10 - S-I-0005759			
			|	ExportShipmentExportRequests.ExportRequest.InternationalFreightReceived КАК InternationalFreightReceived,
			|	ExportShipmentExportRequests.ExportRequest.InternationalFreightSubmittedForApproval КАК InternationalFreightSubmittedForApproval,
			|	ExportShipmentExportRequests.ExportRequest.InternationalFreightApproved КАК InternationalFreightApproved,
			|	ExportShipmentExportRequests.ExportRequest.ConsigneeGLReceived КАК ConsigneeGLReceived,
			|	StagesOfExportRequests.Stage КАК Stage
			
			|ИЗ
			|	Документ.ExportShipment.ExportRequests КАК ExportShipmentExportRequests
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfExportRequests КАК StagesOfExportRequests
			|		ПО ExportShipmentExportRequests.ExportRequest = StagesOfExportRequests.ExportRequest
			|ГДЕ
			|	ExportShipmentExportRequests.Ссылка = &Ссылка
			|	И НЕ ExportShipmentExportRequests.ExportRequest В (&ExportRequests)");	
			
		СтруктураТекстов.Вставить("СтарыеЗначенияРеквизитовШапки",
			"ВЫБРАТЬ
			|	ExportShipment.SubmittedToCustoms,
			|	ExportShipment.ReleasedFromCustoms,
			|	ExportShipment.InternationalATA,
			|	ExportShipment.InternationalATD
			|ИЗ
			|	Документ.ExportShipment КАК ExportShipment
			|ГДЕ
			|	ExportShipment.Ссылка = &Ссылка");	
			
		СтруктураТекстов.Вставить("ВыборкаПроведенныхInvoiceLinesMatchings",
			"ВЫБРАТЬ
			|	ЗакрытиеПоставки.Представление
			|ИЗ
			|	Документ.ЗакрытиеПоставки КАК ЗакрытиеПоставки
			|ГДЕ
			|	ЗакрытиеПоставки.Проведен
			|	И ЗакрытиеПоставки.Поставка = &Ссылка");	
		
	КонецЕсли;
	       		
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ТаблицаExportRequests", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыExportRequests") Тогда
		ДополнительныеСвойства.ТаблицаExportRequests = СтруктураРезультатов.РеквизитыExportRequests.Выгрузить();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаExportRequestsВПохожихДокументах", Неопределено);
	Если СтруктураРезультатов.Свойство("ExportRequestsВПохожихДокументах") Тогда
		ДополнительныеСвойства.ВыборкаExportRequestsВПохожихДокументах = СтруктураРезультатов.ExportRequestsВПохожихДокументах.Выбрать();
	КонецЕсли;
			
	ДополнительныеСвойства.Вставить("ТаблицаУдаленныхExportRequests", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыУдаленныхExportRequests") Тогда
		ДополнительныеСвойства.ТаблицаУдаленныхExportRequests = СтруктураРезультатов.РеквизитыУдаленныхExportRequests.Выгрузить();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаСтарыхРеквизитовШапки", Неопределено);
	Если СтруктураРезультатов.Свойство("СтарыеЗначенияРеквизитовШапки") Тогда
		ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки = СтруктураРезультатов.СтарыеЗначенияРеквизитовШапки.Выбрать();
		ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки.Следующий();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаПроведенныхInvoiceLinesMatchings", Неопределено);
	Если СтруктураРезультатов.Свойство("ПроведенныеInvoiceLinesMatchings") Тогда
		ДополнительныеСвойства.ВыборкаПроведенныхInvoiceLinesMatchings = СтруктураРезультатов.ПроведенныеInvoiceLinesMatchings.Выбрать();
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыСДополнительнымиДанными(ТаблицаExportRequests)
	
	// { RGS AArsentev 23.08.2016 15:28:45 - S-I-0001816
	//Если НЕ ЗначениеЗаполнено(ProcessLevel) И ЗначениеЗаполнено(ExportSpecialist) Тогда
	//	ProcessLevel = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ExportSpecialist, "ProcessLevel");
	//КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ProcessLevel) и ТаблицаExportRequests.Количество() > 0 Тогда		
		ProcessLevel = ТаблицаExportRequests[0].ProcessLevel;
	КонецЕсли;
	// } RGS AArsentev 23.08.2016 15:28:45 - S-I-0001816
	
	ImportExportКлиентСервер.ЗаполнитьРеквизитыExportShipmentОбщиеДляExportRequests(ЭтотОбъект, ТаблицаExportRequests);
	
	Если ExportRequests.Количество() > 0 Тогда 
		МассивExportRequestsNo = ДополнительныеСвойства.ТаблицаExportRequests.ВыгрузитьКолонку("Номер");
		ExportRequestsNo = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивExportRequestsNo, ", ");
	КонецЕсли;
	
	//Total freight (SLB USD rate) 
	
	TotalFreightSumSLBUSD = 0;
	Если ЗначениеЗаполнено(InternationalATD) Тогда 
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ExportRequests", ExportRequests.ВыгрузитьКолонку("ExportRequest"));
		
		Запрос.Текст = "ВЫБРАТЬ
		|	ExportRequest.LocalFreightSum КАК FreightSum,
		|	ExportRequest.LocalFreightCurrency КАК FreightCurrency
		|ПОМЕСТИТЬ ВТsum
		|ИЗ
		|	Документ.ExportRequest КАК ExportRequest
		|ГДЕ
		|	ExportRequest.Ссылка В(&ExportRequests)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ExportRequest.InternationalFreightSum,
		|	ExportRequest.InternationalFreightCurrency
		|ИЗ
		|	Документ.ExportRequest КАК ExportRequest
		|ГДЕ
		|	ExportRequest.Ссылка В(&ExportRequests)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СУММА(ВТsum.FreightSum) КАК FreightSum,
		|	ВТsum.FreightCurrency
		|ИЗ
		|	ВТsum КАК ВТsum
		|
		|СГРУППИРОВАТЬ ПО
		|	ВТsum.FreightCurrency";
		      				
		ТаблицаExportRequestsFreightSum = Запрос.Выполнить().Выгрузить();
		
		CurrencySLB = CustomsСерверПовтИсп.ПолучитьВалютуПоНаименованию("SLB");
		СтруктураCurrencySLB = ОбщегоНазначения.ПолучитьКурсВалюты(CurrencySLB, InternationalATD);
		
		Для Каждого Стр из ТаблицаExportRequestsFreightSum Цикл
			
			Если Не ЗначениеЗаполнено(Стр.FreightSum) Тогда 
				Продолжить;
			КонецЕсли;
			
			СтруктураCurrency = ОбщегоНазначения.ПолучитьКурсВалюты(Стр.FreightCurrency, InternationalATD);
			
			FreightSumSLB = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(
				Стр.FreightSum, Стр.FreightCurrency, CurrencySLB, 
				СтруктураCurrency.Курс, СтруктураCurrencySLB.Курс, 
				СтруктураCurrency.Кратность, СтруктураCurrencySLB.Кратность); 
				
			TotalFreightSumSLBUSD = TotalFreightSumSLBUSD + FreightSumSLB;
			
		КонецЦикла;
		
	КонецЕсли;
	 	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

// ДОДЕЛАТЬ
Процедура ПроверитьВозможностьИзменения(Отказ)
	
	ВыборкаПроведенныхInvoiceLinesMatchings = ДополнительныеСвойства.ВыборкаПроведенныхInvoiceLinesMatchings;
	Если ВыборкаПроведенныхInvoiceLinesMatchings = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Если ВыборкаПроведенныхInvoiceLinesMatchings.Следующий() Тогда 
		ТекстОшибок = "You can not change """ + ЭтотОбъект + """ because """ + ВыборкаПроведенныхInvoiceLinesMatchings.Представление + """ is posted!";
		ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
		ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ТекстОшибок,
			ЭтотОбъект,,, Отказ);
	КонецЕсли;
		
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи)
	
	ПроверитьЗаполнениеРеквизитовШапки(Отказ, РежимЗаписи, ДополнительныеСвойства.ТаблицаExportRequests);
	
	ПроверитьЗаполнениеРеквизитовТЧExportRequests(
		Отказ,
		РежимЗаписи,
		ДополнительныеСвойства.ТаблицаExportRequests,
		ДополнительныеСвойства.ВыборкаExportRequestsВПохожихДокументах);
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеРеквизитовШапки(Отказ, РежимЗаписи, ТаблицаExportRequests)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ТекстОшибок = "Process level is empty!";
		ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
		ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ТекстОшибок,
			ЭтотОбъект, , , Отказ);
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	// Реквизиты, общие для export requests
	
	Если ExportRequests.Количество() Тогда

		Если Не CustomUnionTransaction И НЕ ЗначениеЗаполнено(CCA) Тогда
			ТекстОшибок = """CCA"" is empty or different in export requests!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "CCA", , Отказ);
		КонецЕсли;
			
		Если НЕ ЗначениеЗаполнено(InternationalFreightProvider) Тогда
			ТекстОшибок = """Int. freight provider"" is different or empty in export requests!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalFreightProvider", , Отказ);
		КонецЕсли;	
			
		Если НЕ CustomUnionTransaction И НЕ ЗначениеЗаполнено(POD) Тогда
			ТекстОшибок = """POD"" is different or empty in export requests!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "POD", , Отказ);
		КонецЕсли;	
		
		Если НЕ ЗначениеЗаполнено(POA) Тогда
			ТекстОшибок = """POA"" is different or empty in export requests!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "POA", , Отказ);
		КонецЕсли;	
		
		Если НЕ ЗначениеЗаполнено(InternationalMOT) Тогда
			ТекстОшибок = """Int. MOT"" is different of empty in export requests!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "InternationalMOT", , Отказ);
		КонецЕсли;	
		
	КонецЕсли;
	
	// Submitted to customs
	Если ЗначениеЗаполнено(SubmittedToCustoms) Тогда
		
		Если ExportRequests.Количество() Тогда
			
			Для Каждого СтрокаТаблицы Из ТаблицаExportRequests Цикл
				
				Если SubmittedToCustoms < СтрокаТаблицы.ConsigneeGLReceived Тогда
						
					ТекстОшибок = """Submitted to customs"" can not be earlier than ""Consignee GL received"" of """ + СтрокаТаблицы.ExportRequest + """!";
					ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
					ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						ТекстОшибок,
						ЭтотОбъект, "SubmittedToCustoms", , Отказ);
						
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// International ETD
	Если ЗначениеЗаполнено(InternationalETD) Тогда
		
		Если ExportRequests.Количество() Тогда
			
			Для Каждого СтрокаТаблицы Из ТаблицаExportRequests Цикл
				
				Если InternationalETD < СтрокаТаблицы.ConsigneeGLRequested Тогда
					
					ТекстОшибок = """Int. ETD"" can not be earlier than ""Consignee GL requested"" of """ + СтрокаТаблицы.ExportRequest + """!";
					ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
					ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						ТекстОшибок,
						ЭтотОбъект, "InternationalETD", , Отказ);
						
				КонецЕсли;
					
			КонецЦикла;
			
		КонецЕсли;
				
	КонецЕсли;
	
КонецПроцедуры
           
Процедура ПроверитьЗаполнениеРеквизитовТЧExportRequests(Отказ, РежимЗаписи, ТаблицаExportRequests, ВыборкаExportRequestsВПохожихДокументах)
	
	Если ПометкаУдаления ИЛИ ExportRequests.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
		
	Пока ВыборкаExportRequestsВПохожихДокументах.Следующий() Цикл  
	
		СтрокаТЧ = ExportRequests.Найти(ВыборкаExportRequestsВПохожихДокументах.ExportRequest, "ExportRequest");	
		ТекстОшибок = """" + ВыборкаExportRequestsВПохожихДокументах.ExportRequest + """ is already in """ + ВыборкаExportRequestsВПохожихДокументах.Представление + """!";
		ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
		ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ТекстОшибок,
			ЭтотОбъект, "ExportRequests[" + (СтрокаТЧ.НомерСтроки-1) + "].ExportRequest", , Отказ);
		
	КонецЦикла;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТаблицы Из ТаблицаExportRequests Цикл
		
		Если СтрокаТаблицы.Canceled Тогда
			
			СтрокаТЧ = ExportRequests.Найти(СтрокаТаблицы.ExportRequest, "ExportRequest");
			ТекстОшибок = """" + СтрокаТЧ.ExportRequest + """ is canceled!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "ExportRequests[" + (СтрокаТЧ.НомерСтроки-1) + "].ExportRequest", , Отказ);		
				
		КонецЕсли;	
		
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.AcceptedBySpecialist) Тогда
			
			СтрокаТЧ = ExportRequests.Найти(СтрокаТаблицы.ExportRequest, "ExportRequest");
			ТекстОшибок = """" + СтрокаТЧ.ExportRequest + """ is not accepted by specialist!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "ExportRequests[" + (СтрокаТЧ.НомерСтроки-1) + "].ExportRequest", , Отказ);		
				
		КонецЕсли;
		
		Если CustomUnionTransaction <> СтрокаТаблицы.CustomUnionTransaction Тогда
				
			СтрокаТЧ = ExportRequests.Найти(СтрокаТаблицы.ExportRequest, "ExportRequest");
			ТекстОшибок = """Custom Union transaction"" in " + СтрокаТаблицы.ExportRequest + """ differs from ""Custom Union transaction"" in current shipment!";
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибок,
				ЭтотОбъект, "ExportRequests[" + (СтрокаТЧ.НомерСтроки-1) + "].ExportRequest",, Отказ);
				
		КонецЕсли;

		Если ЗначениеЗаполнено(SubmittedToCustoms) Тогда
			
			// { RGS DKazanskiy 09.10.2018 12:55:44 - S-I-0005759
			//Если (СтрокаТаблицы.FumigationRequired = Перечисления.YesNo.Yes
			//	ИЛИ СтрокаТаблицы.FumigationCertificateRequired = Перечисления.YesNo.Yes)
			//	И НЕ ЗначениеЗаполнено(СтрокаТаблицы.FumigationDone) Тогда
			//	
			//	СтрокаТЧ = ExportRequests.Найти(СтрокаТаблицы.ExportRequest, "ExportRequest");
			//	ТекстОшибок = """Fumigation done"" in """ + СтрокаТаблицы.ExportRequest + """ is empty!";
			//	ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
			//	ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
			//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			//		ТекстОшибок,
			//		ЭтотОбъект, "ExportRequests[" + (СтрокаТЧ.НомерСтроки-1) + "].ExportRequest",, Отказ);
			//		
			//КонецЕсли;
			// } RGS DKazanskiy 09.10.2018 12:55:56 - S-I-0005759
			
			Если СтрокаТаблицы.PermitsRequired = Перечисления.YesNo.Yes
				И НЕ ЗначениеЗаполнено(СтрокаТаблицы.PermitsObtained) Тогда
				
				СтрокаТЧ = ExportRequests.Найти(СтрокаТаблицы.ExportRequest, "ExportRequest");
				ТекстОшибок = """Permits obtained"" in """ + СтрокаТаблицы.ExportRequest + """ is empty!";
				ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
				ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					ТекстОшибок,
					ЭтотОбъект, "ExportRequests[" + (СтрокаТЧ.НомерСтроки-1) + "].ExportRequest",, Отказ);
					
			КонецЕсли;
			
			Если Не CustomUnionTransaction И НЕ ЗначениеЗаполнено(СтрокаТаблицы.ConsigneeGLReceived) Тогда
				
				СтрокаТЧ = ExportRequests.Найти(СтрокаТаблицы.ExportRequest, "ExportRequest");
				ТекстОшибок = """Consignee GL received"" in """ + СтрокаТаблицы.ExportRequest + """ is empty!";
				ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
				ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					ТекстОшибок,
					ЭтотОбъект, "ExportRequests[" + (СтрокаТЧ.НомерСтроки-1) + "].ExportRequest",, Отказ);
				
			КонецЕсли;
			
			Если Документы.ExportRequest.ПолучитьExportInternationalOBToTMS(СтрокаТаблицы.FromCountry, СтрокаТаблицы.ParentCompany, СтрокаТаблицы.Submitted, СтрокаТаблицы.InternationalMOT, 
				СтрокаТаблицы.InternationalFreightProvider, СтрокаТаблицы.Incoterms, СтрокаТаблицы.BORG, СтрокаТаблицы.CreationDate)
				И НЕ СтрокаТаблицы.InternationalOBSentToTMS Тогда
				
				СтрокаТЧ = ExportRequests.Найти(СтрокаТаблицы.ExportRequest, "ExportRequest");
				ТекстОшибок = "International part of '" + СтрокаТаблицы.ExportRequest + "' is not sent to TMS!";
				ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок);
				ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибок, Истина);
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					ТекстОшибок,
					ЭтотОбъект, "ExportRequests[" + (СтрокаТЧ.НомерСтроки-1) + "].ExportRequest",, Отказ);
				
			КонецЕсли;
			      			
		КонецЕсли;
		
	КонецЦикла;	
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// ПРИ ЗАПИСИ

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ЗарегистрироватьTMSClearanceEvents(ДополнительныеСвойства.ТаблицаExportRequests);
	
	// S-I-0000713 - terminate transmission of shipment events from 1C to TMS for export domestic and international shipments
	//ЗарегистрироватьTMSInternationalExportGateInGateOutEvents(ДополнительныеСвойства.ТаблицаExportRequests);
	
	ОбновитьStagesOfExportRequests(
		ДополнительныеСвойства.ТаблицаExportRequests,
		ДополнительныеСвойства.ТаблицаУдаленныхExportRequests);
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

Процедура ОбновитьStagesOfExportRequests(ТаблицаExportRequests, ТаблицаУдаленныхExportRequests)
	
	Если ExportRequests.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Обновим Stage в текущих Export requests
	Для Каждого СтрокаТаблицы Из ТаблицаExportRequests Цикл
		
		Если ПометкаУдаления Тогда
			NewStage = ImportExportСервер.ПолучитьExportRequestStage(СтрокаТаблицы, Неопределено);			
		Иначе
			NewStage = ImportExportСервер.ПолучитьExportRequestStage(СтрокаТаблицы, ЭтотОбъект);
		КонецЕсли;
		
		Если NewStage = СтрокаТаблицы.Stage Тогда
			Продолжить;
		КонецЕсли;
		
		МенеджерЗаписи = РегистрыСведений.StagesOfExportRequests.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.ExportRequest = СтрокаТаблицы.ExportRequest;
		МенеджерЗаписи.Stage = NewStage;
		МенеджерЗаписи.ModificationDate = ТекущаяДата();
		МенеджерЗаписи.Записать(Истина);
		
	КонецЦикла;
	
	// Обновим Stage в удаленных Export requests
	Если ТаблицаУдаленныхExportRequests <> Неопределено Тогда
		
		Для Каждого СтрокаТаблицы Из ТаблицаУдаленныхExportRequests Цикл
			
			NewStage = ImportExportСервер.ПолучитьExportRequestStage(СтрокаТаблицы, Неопределено);
			
			Если NewStage = СтрокаТаблицы.Stage Тогда
				Продолжить;
			КонецЕсли;
			
			МенеджерЗаписи = РегистрыСведений.StagesOfExportRequests.СоздатьМенеджерЗаписи();
			МенеджерЗаписи.ExportRequest = СтрокаТаблицы.ExportRequest;
			МенеджерЗаписи.Stage = NewStage;
			МенеджерЗаписи.ModificationDate = ТекущаяДата();
			МенеджерЗаписи.Записать(Истина);
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗарегистрироватьTMSClearanceEvents(ТаблицаExportRequests)
	
	Если ExportRequests.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ToTMS = Ложь;
	Для Каждого СтрокаТаблицы Из ТаблицаExportRequests Цикл
		Если ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТаблицы.ExportRequest, "InternationalOBSentToTMS") Тогда
			ToTMS = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если НЕ ToTMS Тогда
		Возврат;
	КонецЕсли;
		
	// Определим значения старых реквизитов	
	СтарыйSubmittedToCustoms = '00010101';
	СтарыйReleasedFromCustoms = '00010101';
		
	Если НЕ ПометкаУдаления И ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки <> Неопределено Тогда
		
		ВыборкаСтарыхРеквизитовШапки = ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки;
		СтарыйSubmittedToCustoms = ВыборкаСтарыхРеквизитовШапки.SubmittedToCustoms;
		СтарыйReleasedFromCustoms = ВыборкаСтарыхРеквизитовШапки.ReleasedFromCustoms;
				
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);

	ExportClearanceEventsQueue = РегистрыСведений.ExportClearanceEventsQueue;
	ClearanceEventsTypes = Перечисления.ClearanceEventsTypes;
	
	ExportClearanceEventsQueue.ЗарегистрироватьEventПриНеобходимости(
		Ссылка,
		ClearanceEventsTypes.InCustoms,
		СтарыйSubmittedToCustoms,
		SubmittedToCustoms,
		ПараметрыСеанса.ТекущийПользователь);
		
	ExportClearanceEventsQueue.ЗарегистрироватьEventПриНеобходимости(
		Ссылка,
		ClearanceEventsTypes.Cleared,
		СтарыйReleasedFromCustoms,
		ReleasedFromCustoms,
		ПараметрыСеанса.ТекущийПользователь);	
			       	
КонецПроцедуры

Процедура ЗарегистрироватьTMSInternationalExportGateInGateOutEvents(ТаблицаExportRequests)
	
	Если ExportRequests.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	    	
	// Определим значения старых реквизитов
	СтарыйSubmittedToCustoms = '00010101';
	СтарыйInternationalATD   = '00010101';
	СтарыйInternationalATA   = '00010101';
	
	Если НЕ ПометкаУдаления И ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки <> Неопределено Тогда
		
		ВыборкаСтарыхРеквизитовШапки = ДополнительныеСвойства.ВыборкаСтарыхРеквизитовШапки;
		СтарыйSubmittedToCustoms = ВыборкаСтарыхРеквизитовШапки.SubmittedToCustoms;
		СтарыйInternationalATD   = ВыборкаСтарыхРеквизитовШапки.InternationalATD;
		СтарыйInternationalATA   = ВыборкаСтарыхРеквизитовШапки.InternationalATA;
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	InternationalExportGateInGateOutEventsQueue = РегистрыСведений.InternationalExportGateInGateOutEventsQueue;
	GateInGateOutEventsTypes = Перечисления.GateInGateOutEventsTypes;
	
	Для Каждого СтрокаТаблицы Из ТаблицаExportRequests Цикл
		
		Если Не ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТаблицы.ExportRequest, "InternationalOBSentToTMS") Тогда
			Продолжить;
		КонецЕсли;
		
		InternationalExportGateInGateOutEventsQueue.ЗарегистрироватьEventПриНеобходимости(
			Ссылка,
			GateInGateOutEventsTypes.GateInSource,
			СтарыйSubmittedToCustoms,
			SubmittedToCustoms);
		
		InternationalExportGateInGateOutEventsQueue.ЗарегистрироватьEventПриНеобходимости(
			Ссылка,
			GateInGateOutEventsTypes.GateOutSource,
			СтарыйInternationalATD,
			InternationalATD);
		
		InternationalExportGateInGateOutEventsQueue.ЗарегистрироватьEventПриНеобходимости(
			Ссылка,
			GateInGateOutEventsTypes.GateInDestination,
			СтарыйInternationalATA,      
			InternationalATA);
		
		InternationalExportGateInGateOutEventsQueue.ЗарегистрироватьEventПриНеобходимости(
			Ссылка,
			GateInGateOutEventsTypes.GateOutDestination,
			СтарыйInternationalATA,      
			InternationalATA);	
		
	КонецЦикла;
	       	 			       	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПРОВЕДЕНИЯ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ДвиженияПоExportItemsWithoutCustomsFiles();
			 
КонецПроцедуры

Процедура ДвиженияПоExportItemsWithoutCustomsFiles()
	
	ДвиженияExportItemsWithoutCustomsFiles = Движения.ExportItemsWithoutCustomsFiles;
	ДвиженияExportItemsWithoutCustomsFiles.Очистить();
	ДвиженияExportItemsWithoutCustomsFiles.Записывать = Истина;
		
	Если Не ЗначениеЗаполнено(SubmittedToCustoms) Тогда 
		Возврат;
	КонецЕсли;	
	
	ЗапросItems = Новый Запрос;
	ЗапросItems.УстановитьПараметр("ExportRequests", ExportRequests.ВыгрузитьКолонку("ExportRequest"));
	ЗапросItems.Текст =
		"ВЫБРАТЬ
		|	Items.Ссылка,
		|	Items.ExportRequest
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК Items
		|ГДЕ
		|	НЕ Items.ПометкаУдаления
		|	И Items.ExportRequest В(&ExportRequests)";
	
	ВыборкаItems = ЗапросItems.Выполнить().Выбрать();
	Пока ВыборкаItems.Следующий() Цикл
		
		ДвиженияExportItemsWithoutCustomsFiles.ДобавитьЗапись(
			ВидДвиженияНакопления.Приход,
			SubmittedToCustoms,
			ВыборкаItems.Ссылка,
			ВыборкаItems.ExportRequest,
			Ссылка);
				
	КонецЦикла;
	
КонецПроцедуры

Процедура ПоместитьТекстОшибкиВДополнительныеСвойства(ТекстОшибки, СообщениеRIET = Ложь)
	
	ИмяСвойства = ?(СообщениеRIET, "ОписаниеОшибокRIET", "ОписаниеОшибок");
	
	Если НЕ ДополнительныеСвойства.Свойство(ИмяСвойства) Тогда
		ДополнительныеСвойства.Вставить(ИмяСвойства, "");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить(ИмяСвойства, ДополнительныеСвойства[ИмяСвойства] + ТекстОшибки + Символы.ПС);
	
КонецПроцедуры
