
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.RentalTrucksCostsSums") Тогда
		RentalCost = ДанныеЗаполнения.Ссылка;
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
	
	Если Не ПометкаУдаления И Выполнена
		И Status = Перечисления.StatusesOfApproval.Rejected Тогда
		
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
	
	Если Не ЗначениеЗаполнено(ApprovalLevel) Тогда 
		ApprovalLevel = Перечисления.ApprovalLevels.Level1;
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
	
	ОтправитьУведомление();
	
КонецПроцедуры

Процедура ОтправитьУведомление()
	
	УстановитьПривилегированныйРежим(Истина);
	Тело = "";
	Если Status = Перечисления.StatusesOfApproval.SentForApproval Тогда
		
		Тема = СокрЛП(RentalCost) + " requires approval ";
		Тело = СокрЛП(RentalCost) + " was sent for approval by " + ПараметрыСеанса.ТекущийПользователь;
		
		Адрес = ПолучитьАдресApprovalManager();
		
	ИначеЕсли Status = Перечисления.StatusesOfApproval.Canceled Тогда

		Тема = СокрЛП(RentalCost) + " approval was canceled ";
		Тело = СокрЛП(RentalCost) + " approval was canceled by " + ПараметрыСеанса.ТекущийПользователь;
				
		Адрес = ПолучитьАдресApprovalManager();
			
	КонецЕсли;
	
	Тело = ДобавитьСсылкуНаApproval(Тело);
	
	Если ЗначениеЗаполнено(Адрес) Тогда 
		РГСофт.ЗарегистрироватьПочтовоеСообщение(Адрес, Тема, Тело);
	КонецЕсли;
		
КонецПроцедуры

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
	
	ПолнаяСсылка = "http://ru0149app35.dir.slb.com/RIET/#e1cib/list/Task.RentalCostsApproval";
	HTMLСсылка = "<a href=""" + ПолнаяСсылка + """>" + ПолнаяСсылка + "</a>";
	Возврат Текст + "<br>
		|
		|Link to the Rental costs  approval desktop: " + HTMLСсылка;
		
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
	
	CostSum = 0;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	RentalTrucksCostsSumsRentalTrucks.Cost КАК Cost,
	|	RentalTrucksCostsSumsRentalTrucks.Currency,
	|	RentalTrucksCostsSumsRentalTrucks.Ссылка.Дата
	|ИЗ
	|	Документ.RentalTrucksCostsSums.RentalTrucks КАК RentalTrucksCostsSumsRentalTrucks
	|ГДЕ
	|	RentalTrucksCostsSumsRentalTrucks.Ссылка = &RentalCost";
	Запрос.УстановитьПараметр("RentalCost", RentalCost);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		CostSum = 0;
	Иначе
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			CostSum = CostSum + LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(Выборка.Cost, Выборка.Currency, Выборка.Дата);
		КонецЦикла;
	КонецЕсли;
	
	СтруктураBaseCostsSumLimit = РегистрыСведений.BaseCostsSumLimitForApproval.ПолучитьПоследнее(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(RentalCost, "Дата"));
	
	Возврат (CostSum > СтруктураBaseCostsSumLimit.LimitForApprovalLevel2);
	
КонецФункции

