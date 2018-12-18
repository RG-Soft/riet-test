
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("СтруктураНастройки") Тогда		
		
		Этаформа.Элементы.Список.РежимВыбора = Истина;
		
		Если Параметры.СтруктураНастройки.Имя = "ВыборИзAPInvoice" Тогда
			
			СтруктураНастройки = Параметры.СтруктураНастройки;
			ТаблицаTrips = Документы.APInvoice.НастроитьДляВыбораИзAPInvoice(СтруктураНастройки.ServiceProvider, СтруктураНастройки.LegalEntity);
			МассивTrips = ТаблицаTrips.ВыгрузитьКолонку("Trip");
			СписокTrips = Новый СписокЗначений; 
			СписокTrips.ЗагрузитьЗначения(МассивTrips);
			
			ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список,
			"Trip",
			СписокTrips,
			ВидСравненияКомпоновкиДанных.ВСписке,
			,
			Истина,
			РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
			
		ИначеЕсли Параметры.СтруктураНастройки.Имя = "ВыборИзRentalTracking" Тогда
			
			СтруктураНастройки = Параметры.СтруктураНастройки;
			ТаблицаTrips = Документы.RentalTrucksCostsSums.НастроитьДляВыбораИзRentalTracking(СтруктураНастройки.ServiceProvider, СтруктураНастройки.ДатаНачала, СтруктураНастройки.ДатаОкончания);
			МассивTrips = ТаблицаTrips.ВыгрузитьКолонку("Trip");
			СписокTrips = Новый СписокЗначений; 
			СписокTrips.ЗагрузитьЗначения(МассивTrips);
			
			ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список,
			"Trip",
			СписокTrips,
			ВидСравненияКомпоновкиДанных.ВСписке,
			,
			Истина,
			РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
			
		КонецЕсли;
		
	Иначе 
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список,
		"Specialist",
		ПараметрыСеанса.ТекущийПользователь,
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Ложь,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список,
		"Stage",
		,
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Ложь,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список,
		"Ссылка.ПометкаУдаления",
		Ложь,
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Истина,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура OpenFSTracking(Команда)
	
	ТекДанные = Элементы.Список.ТекущиеДанные;
	
	Если ЗначениеЗаполнено(ТекДанные.FSTracking) Тогда 
		ПоказатьЗначение(,ТекДанные.FSTracking);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ChangeNavigationType(Команда)
	
	ДопПараметры = Новый Массив;
	ДопПараметры.Добавить(Элементы.Список.ВыделенныеСтроки);
	Оповещение = Новый ОписаниеОповещения("EditNavigationType", ЭтотОбъект, ДопПараметры);	
		
	ПоказатьВводЗначения(
	Оповещение, 
	ПредопределенноеЗначение("Перечисление.SummerWinter.ПустаяСсылка"),
	?(РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS(), "Измение типа навигации", "Edit navigation type"), 
	Тип("ПеречислениеСсылка.SummerWinter")
	);
	
КонецПроцедуры

&НаСервере
Процедура EditNavigationType(NewType, Параметры) Экспорт

	Если NewType <> Неопределено Тогда
		
		УстановитьПривилегированныйРежим(Истина);
		
		Для Каждого Элемент из Параметры[0] Цикл
			Trip = Элемент.ПолучитьОбъект();
			OldType = Trip.NavigationType;
			Trip.NavigationType = NewType;
			Trip.ОбменДанными.Загрузка = Истина;
			Попытка
				
				МенеджерЗаписи = РегистрыСведений.TripNonLawsonCompaniesLogs.СоздатьМенеджерЗаписи();
				МенеджерЗаписи.LogTo = Trip.Ссылка;
				МенеджерЗаписи.Date	= ТекущаяДата();
				МенеджерЗаписи.LogType	= Справочники.LogTypes.ИзменениеРеквизитов;
				МенеджерЗаписи.User	= ПараметрыСеанса.ТекущийПользователь;
				МенеджерЗаписи.Text	= "Изменён реквизит 'Mobilization type' - Прежний: " + OldType + ", Новый: " + NewType;
				МенеджерЗаписи.Записать();
				
				Trip.Записать();
				
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to save new navigation type!");
			КонецПопытки;
		КонецЦикла;
		
		УстановитьПривилегированныйРежим(Ложь);
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Edit completed");	
		
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ChangeAdditionalVolume(Команда)
	ДопПараметры = Новый Массив;
	ДопПараметры.Добавить(Элементы.Список.ВыделенныеСтроки);
	Оповещение = Новый ОписаниеОповещения("EditAdditionalVolume", ЭтотОбъект, ДопПараметры);	
		
	ПоказатьВводЗначения(
	Оповещение, 
	ПредопределенноеЗначение("Перечисление.YesNo.ПустаяСсылка"),
	?(РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS(), "Измение признака доп. объёма", "Edit addtional volume"), 
	Тип("ПеречислениеСсылка.YesNo")
	);
КонецПроцедуры

&НаСервере
Процедура EditAdditionalVolume(NewVolume, Параметры) Экспорт

	Если NewVolume <> Неопределено Тогда
		
		УстановитьПривилегированныйРежим(Истина);
		
		Если NewVolume = Перечисления.YesNo.Yes Тогда
			AdditionalVolume = Истина;
		Иначе
			AdditionalVolume = Ложь;
		КонецЕсли;
		
		Для Каждого Элемент из Параметры[0] Цикл
			РеквизитыТрипа = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Элемент, "NavigationType,AdditionalVolume");
			Если ЗначениеЗаполнено(РеквизитыТрипа.NavigationType) И РеквизитыТрипа.NavigationType <> Перечисления.SummerWinter.NA 
					И РеквизитыТрипа.AdditionalVolume <> AdditionalVolume Тогда
				Trip = Элемент.ПолучитьОбъект();
				Trip.AdditionalVolume = AdditionalVolume;
				Trip.ОбменДанными.Загрузка = Истина;
				Попытка
					Trip.Записать();
				Исключение
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Failed to change 'Additional Volume'!");
				КонецПопытки;
			КонецЕсли;
		КонецЦикла;
		
		УстановитьПривилегированныйРежим(Ложь);
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Edit completed");
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ChangeMileage(Команда)
	
	ДопПараметры = Новый Структура();
	ДопПараметры.Вставить("Trip",Элементы.Список.ТекущаяСтрока);

	Оповещение = Новый ОписаниеОповещения("ИзменитьMileage", ЭтотОбъект, ДопПараметры); 
	ОткрытьФорму("ОбщаяФорма.ФормаРедактированияMilageInTrip", ДопПараметры , , , , , Оповещение);
	
КонецПроцедуры

Процедура ИзменитьMileage(Результат, ДополнительныеПараметры) Экспорт

КонецПроцедуры


&НаСервереБезКонтекста
Функция CreateTransportRegistersНаСервере(ВыделенныеДокументы)
	
	Если ВыделенныеДокументы.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Документы.APInvoice.РазнестиТрипы(ВыделенныеДокументы);
	
КонецФункции


&НаКлиенте
Процедура CreateTransportRegisters(Команда)
	
	// find all selected rows and slit them into groups by BORG-ParentCompany-AU combinations
	
	ВыделенныеДокументы = Новый Массив;
	Для каждого ТекВыделеннаяСтрока ИЗ Элементы.Список.ВыделенныеСтроки Цикл
		
		ДанныеСтроки = Элементы.Список.ДанныеСтроки(ТекВыделеннаяСтрока);
		ВыделенныеДокументы.Добавить(ДанныеСтроки.Ссылка);
		
	КонецЦикла;
	
	Если ВыделенныеДокументы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Ответ = CreateTransportRegistersНаСервере(ВыделенныеДокументы);
	
	Если Ответ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого ТекСообщение из Ответ.Сообщения Цикл
		Сообщить(ТекСообщение, СтатусСообщения.Важное);
	КонецЦикла;
	
	Для каждого ТекДокумент из Ответ.Документы Цикл
		
		//Сообщить("Создан документ: " + Строка(ТекДокумент), СтатусСообщения.Информация);
		ПоказатьЗначение(, ТекДокумент);
		
	КонецЦикла;	
	
КонецПроцедуры

