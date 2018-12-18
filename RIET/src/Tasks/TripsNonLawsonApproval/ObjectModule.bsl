
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.TripNonLawsonCompanies") Тогда
		Trip = ДанныеЗаполнения.Ссылка;
		Specialist = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка = Истина Тогда 
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ApprovalLevel) Тогда 
		ApprovalLevel = Перечисления.ApprovalLevels.Level1;
	КонецЕсли;
	
	ПроверитьВозвожностьИзменения(Отказ);
	
	Если Отказ Тогда 
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Specialist) Тогда
		Specialist = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	
	Если ПометкаУдаления Тогда 
		
		Status = Перечисления.StatusesOfApproval.Canceled;
		Выполнена = Ложь;
		ApprovalManager = Неопределено;
		ExecutionDate = Неопределено;
		ReasonOfRejection = Неопределено;
		ApprovalLevel = Неопределено;
		PreviouslyApproved = Неопределено;
		PreviouslyApprovedBy = Неопределено;
		
	иначе
		
		Если Не Выполнена Тогда
			Status = Перечисления.StatusesOfApproval.SentForApproval;
			Дата = ТекущаяДата();	
		КонецЕсли;
		
		InformationForApproval = СокрЛП(InformationForApproval);
		ReasonOfRejection = СокрЛП(ReasonOfRejection);
			
	КонецЕсли;

КонецПроцедуры

Процедура ПроверитьВозвожностьИзменения(Отказ)
	         	
	TripStage = РегистрыСведений.StagesOfTripsNonLawsonCompanies.ОпределитьStage(Trip);
	ДополнительныеСвойства.Вставить("TripStage", TripStage);
	
	Если TripStage = Перечисления.TripNonLawsonCompaniesStages.Closed Тогда 
		
		Сообщить("Trip was closed / Поставка закрыта!");
		Отказ = Истина;
		
	ИначеЕсли Не ПометкаУдаления
		И (TripStage = Перечисления.TripNonLawsonCompaniesStages.Draft
		ИЛИ TripStage = Перечисления.TripNonLawsonCompaniesStages.Saved_ApprovalIsNotRequired) Тогда 
		
		Сообщить("Approval is not required / Утверждение не требуется!");
		Отказ = Истина;
		
	ИначеЕсли Не ПометкаУдаления
		И Status = Перечисления.StatusesOfApproval.SentForApproval
		И TripStage = Перечисления.TripNonLawsonCompaniesStages.AwaitingApproval Тогда 
		
		Сообщить("Approval was sent / Утверждение было отправлено!");
		Отказ = Истина;

	ИначеЕсли Не ПометкаУдаления И Выполнена
		И Status = Перечисления.StatusesOfApproval.Approved 
		И TripStage = Перечисления.TripNonLawsonCompaniesStages.Approved Тогда 
		
		Сообщить("Already approved / Утверждено ранее!");
		Отказ = Истина;

	ИначеЕсли Не ПометкаУдаления И Выполнена
		И Status = Перечисления.StatusesOfApproval.Rejected 
		И TripStage = Перечисления.TripNonLawsonCompaniesStages.Rejected Тогда 
		
		Сообщить("Already rejected / Отклонено ранее!");
		Отказ = Истина;
		
	ИначеЕсли ПометкаУдаления 
		И Status = Перечисления.StatusesOfApproval.Canceled Тогда 
		
		Сообщить("Already canceled / Отменено ранее!");
		Отказ = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередВыполнением(Отказ)
	      		
	Если ПометкаУдаления Тогда 
		
		Сообщить("Approval was canceled / Утверждение было отменено!");
		Отказ = Истина;

	КонецЕсли;

	Если Отказ Тогда 
		Возврат;
	КонецЕсли;

	ТекПользователь = ПараметрыСеанса.ТекущийПользователь;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ApprovalLevel", ApprovalLevel);
	Запрос.УстановитьПараметр("ApprovalManager", ТекПользователь);

	Запрос.Текст = "ВЫБРАТЬ
	               |	TripsNonLawsonApprovalManagers.ApprovalManager
	               |ИЗ
	               |	РегистрСведений.TripsNonLawsonApprovalManagers КАК TripsNonLawsonApprovalManagers
	               |ГДЕ
	               |	TripsNonLawsonApprovalManagers.ApprovalLevel = &ApprovalLevel
	               |	И TripsNonLawsonApprovalManagers.ApprovalManager = &ApprovalManager";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда 
		
		ApprovalManager = ТекПользователь;
		ExecutionDate = ТекущаяДата();
		
	иначе
		
		Сообщить("You do not have rights for current approval level / Нет прав на текущий уровень утверждения!");
		Отказ = Истина;
		
	КонецЕсли;
	  		
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка = Истина Тогда 
		Возврат;
	КонецЕсли;

	Если Отказ Тогда 
		Возврат;
	КонецЕсли;
	
	ОбновитьStageTrip();
	
	ОтправитьУведомление();
	
КонецПроцедуры

Процедура ОбновитьStageTrip()
	
	УстановитьПривилегированныйРежим(Истина);
	
	NewStage = РегистрыСведений.StagesOfTripsNonLawsonCompanies.ПолучитьTripStage(Trip);
	
	Если Не ДополнительныеСвойства.Свойство("TripStage") 
		ИЛИ ДополнительныеСвойства.TripStage = NewStage Тогда
		Возврат;
	КонецЕсли;
	  		
	МенеджерЗаписи = РегистрыСведений.StagesOfTripsNonLawsonCompanies.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Trip = Trip;
	МенеджерЗаписи.Stage = NewStage;                          
	МенеджерЗаписи.ModificationDate = ТекущаяДата();
	МенеджерЗаписи.Записать(Истина);
	   	
КонецПроцедуры

Процедура ОтправитьУведомление()
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Status = Перечисления.StatusesOfApproval.SentForApproval Тогда
		
		Тема = СокрЛП(Trip) + " requires approval ";
		Тело = СокрЛП(Trip) + " was sent for approval by " + ПараметрыСеанса.ТекущийПользователь;
		
		Адрес = ПолучитьАдресApprovalManager();
		
	ИначеЕсли Status = Перечисления.StatusesOfApproval.Canceled Тогда

		Тема = СокрЛП(Trip) + " approval was canceled ";
		Тело = СокрЛП(Trip) + " approval was canceled by " + ПараметрыСеанса.ТекущийПользователь;
				
		Адрес = ПолучитьАдресApprovalManager();
		
	ИначеЕсли Status = Перечисления.StatusesOfApproval.Approved Тогда
		
		Тема = СокрЛП(Trip) + " approved ";
		Тело = СокрЛП(Trip) + " approved by " + ПараметрыСеанса.ТекущийПользователь;
				
		Адрес = ПолучитьАдресSpecialist();
		
	ИначеЕсли Status = Перечисления.StatusesOfApproval.Rejected Тогда
		
		Тема = СокрЛП(Trip) + " rejected ";
		Тело = СокрЛП(Trip) + " rejected by " + ПараметрыСеанса.ТекущийПользователь;
		
		Адрес = ПолучитьАдресSpecialist();
		
	КонецЕсли;
	
	Тело = ДобавитьСсылкуНаApproval(Тело);
	
	Если ЗначениеЗаполнено(Адрес) Тогда 
		РГСофт.ЗарегистрироватьПочтовоеСообщение(Адрес, Тема, Тело);
	КонецЕсли;
		
КонецПроцедуры

Функция ПолучитьАдресSpecialist()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Trip", Trip);
	Запрос.УстановитьПараметр("Specialist", Specialist);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	TripNonLawsonCompanies.Specialist.EMail КАК EMail
	               |ИЗ
	               |	Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	               |ГДЕ
	               |	TripNonLawsonCompanies.Ссылка = &Trip
	               |
	               |ОБЪЕДИНИТЬ
	               |
	               |ВЫБРАТЬ
	               |	Пользователи.EMail
	               |ИЗ
	               |	Справочник.Пользователи КАК Пользователи
	               |ГДЕ
	               |	Пользователи.Ссылка = &Specialist";
	
	МассивEmails = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("EMail");
	
	Возврат РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивEmails, ";");
		
КонецФункции

Функция ПолучитьАдресApprovalManager()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ApprovalLevel", ApprovalLevel);
	Запрос.Текст = "ВЫБРАТЬ
	               |	TripsNonLawsonApprovalManagers.ApprovalManager.EMail КАК EMail
	               |ИЗ
	               |	РегистрСведений.TripsNonLawsonApprovalManagers КАК TripsNonLawsonApprovalManagers
	               |ГДЕ
	               |	TripsNonLawsonApprovalManagers.ApprovalLevel = &ApprovalLevel";
	
	МассивEmails = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("EMail");
	
	Возврат РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивEmails, ";");
		
КонецФункции

Функция ДобавитьСсылкуНаApproval(Текст)
	  	
	//НавигационнаяСсылка = ПолучитьНавигационнуюСсылку(Ссылка);
	//НавигационнаяСсылка = СтрЗаменить(НавигационнаяСсылка, """", "'");
	//ПолнаяСсылка = "http://ru0149app35.dir.slb.com/RIET/#" + НавигационнаяСсылка;
	//HTMLСсылка = "<a href=""" + ПолнаяСсылка + """>" + ПолнаяСсылка + "</a>";
	//Текст = Текст + "<br>
	//	|Link to the approval / Ссылка на утверждение: " + HTMLСсылка;
		
	ПолнаяСсылка = "http://ru0149app35.dir.slb.com/RIET/#e1cib/list/Task.TripsNonLawsonApproval";
	HTMLСсылка = "<a href=""" + ПолнаяСсылка + """>" + ПолнаяСсылка + "</a>";
	Возврат Текст + "<br>
		|
		|Link to the trips approval desktop: " + HTMLСсылка;
		
КонецФункции 

Процедура ПриВыполнении(Отказ)
	
	Если ApprovalLevel = Перечисления.ApprovalLevels.Level2
		Или Status = Перечисления.StatusesOfApproval.Rejected 
		Или Не ТребуетсяУтверждениеLevel2() Тогда
		Возврат;
	КонецЕсли;
	 				
	PreviouslyApprovedBy = ApprovalManager;
	PreviouslyApproved = ExecutionDate;
	
	Выполнена = Ложь;
	ApprovalLevel = Перечисления.ApprovalLevels.Level2;
	
	ApprovalManager = Неопределено;
	ExecutionDate = Неопределено;
	   	
КонецПроцедуры
	
Функция ТребуетсяУтверждениеLevel2()
	
	СтруктураРеквизитовTrip = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Trip, "Дата,BaseCostsSumSLBUSD");
	
	СтруктураBaseCostsSumLimit = РегистрыСведений.BaseCostsSumLimitForApproval.ПолучитьПоследнее(СтруктураРеквизитовTrip.Дата);
	
	Возврат (СтруктураРеквизитовTrip.BaseCostsSumSLBUSD > СтруктураBaseCostsSumLimit.LimitForApprovalLevel2);
	 	
КонецФункции

