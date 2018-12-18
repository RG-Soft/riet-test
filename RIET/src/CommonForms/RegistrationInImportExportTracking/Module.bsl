
//////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

// ПРИ СОЗДАНИИ НА СЕРВЕРЕ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	SupportEmailAddress = "riet-support@slb.com";
	LinkForRegisteredUsers = "http://ru0149app35.dir.slb.com/RIET";
	
	Элементы.ГруппаRegistered.Видимость = Ложь;	
	Элементы.ГруппаAlreadyRegistered.Видимость = Ложь;
	Элементы.ГруппаError.Видимость = Ложь;	
	// { RG-Soft LGoncharova 12.11.2018 S-I-0006256
	Элементы.ГруппаОшибка.Видимость = Ложь;	
	// } RG-Soft LGoncharova 12.11.2018 S-I-0006256
	
КонецПроцедуры

// { RG-Soft LGoncharova 12.11.2018 S-I-0006256
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПоказатьФормуПредупреждения();
КонецПроцедуры
&НаКлиенте
Процедура ПоказатьФормуПредупреждения()
	__ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаПредупреждения",ЭтаФорма , "СогласиеНаРегистрацию");
	ОткрытьФорму("ОбщаяФорма.rgsФормаПредупрежденияПриРегистрации",, ЭтаФорма,,,,__ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПРоцедуры
&НаКлиенте
Процедура ОбработкаПредупреждения(СтатусВозврата, ИмяПараметра) Экспорт
	Если ИмяПараметра = "СогласиеНаРегистрацию" И НЕ СтатусВозврата = Истина Тогда
		Элементы.ГруппаRegister.ТолькоПросмотр 				 = Истина;
		Элементы.ГруппаLinkForRegisteredUsers.ТолькоПросмотр = Истина;
		Элементы.Register.Доступность 						 = Ложь;
		Элементы.ГруппаRegistered.Видимость 		= Ложь;
		Элементы.ГруппаAlreadyRegistered.Видимость 	= Ложь;
		Элементы.ГруппаError.Видимость 				= Ложь;
		Элементы.ГруппаОшибка.Видимость 			= Истина;
		Возврат;
	КонецЕсли;
КонецПроцедуры
// } RG-Soft LGoncharova 12.11.2018 S-I-0006256

//////////////////////////////////////////////////////////////////////
// РЕГИСТРАЦИЯ

&НаКлиенте
Процедура Register(Команда)
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(Alias)) Тогда
		Предупреждение("Fill in Alias, please.");
		Возврат;
	КонецЕсли;
	
	RegisterНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура RegisterНаСервере()
	
	СтруктураВозврата = CreateUpdateUser();
	
	Если СтруктураВозврата.Результат = "Registered" Тогда
		
		Элементы.ГруппаRegister.Видимость = Ложь;
		Элементы.ГруппаRegistered.Видимость = Истина;
		
	ИначеЕсли СтруктураВозврата.Результат = "AlreadyRegistered" Тогда
		
		Элементы.ГруппаRegister.Видимость = Ложь;
		Элементы.НадписьAUserWithTeAlias.Заголовок = СтрЗаменить(Элементы.НадписьAUserWithTeAlias.Заголовок, "%1", Alias);
		Элементы.ГруппаAlreadyRegistered.Видимость = Истина;	
				
	Иначе
		
		Элементы.НадписьErrorDescription.Заголовок = СтруктураВозврата.Описание;
		Элементы.ГруппаError.Видимость = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

// ДОДЕЛАТЬ
&НаСервере
Функция CreateUpdateUser()
	
	// ВЫНЕСТИ ЧАСТЬ ЛОГИКИ В МОДУЛЬ МЕНЕДЖЕРА СПРАВОЧНИКА ПОЛЬЗОВАТЕЛИ
	
	СтруктураВозврата = Новый Структура("Результат, Описание");
	
	// пока для всех DIR
	//Domain = СокрЛП(Domain);
	//Domain = НРег(Domain);
	Domain = "dir";
	
	Alias = СокрЛП(Alias);	
	Если СтрДлина(СокрЛП(Alias)) > 2 Тогда 
		Alias = ВРег(Сред(СокрЛП(Alias), 1, 2)) + НРег(Сред(СокрЛП(Alias), 3));
	иначе
		Alias = ВРег(СокрЛП(Alias));
	КонецЕсли;
	Alias = СтрЗаменить(Alias, "@slb.com", "");
	НовыйПользовательОС = "\\" + Domain + "\" + Alias;
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Проверим - не зарегистрирован ли пользователь 
	МассивПользователейИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого ПользовательИБ Из МассивПользователейИБ Цикл
		
		ПользовательОСПользователяИБ = СокрЛП(ПользовательИБ.ПользовательОС);
		Если Прав(ПользовательОСПользователяИБ, 1) = "\" Тогда // Срезаем последний слеш, если есть
			ПользовательОСПользователяИБ = Лев(ПользовательОСПользователяИБ, СтрДлина(ПользовательОСПользователяИБ)-1);
		КонецЕсли;
		
		// А ЕСЛИ ЗДЕСЬ НЕ 3 А 2 ИЛИ БОЛЬШЕ БУКВ?
		AliasТекущегоПользователяИБ = Сред(ПользовательОСПользователяИБ, 7); // Срезаем \\EUR\	
		
		Если НРег(AliasТекущегоПользователяИБ) = Alias Тогда
			
			Если НРег(ПользовательОСПользователяИБ) = НРег(НовыйПользовательОС) Тогда
				
				СтруктураВозврата.Результат = "AlreadyRegistered";
				Возврат СтруктураВозврата;
				
			Иначе
				
				ПользовательИБ.ПользовательОС = НовыйПользовательОС;
				Попытка
					ПользовательИБ.Записать();
				Исключение
					
					ЗаписьЖурналаРегистрации(
						"Ошибка обновления данных пользователя ИБ",
						УровеньЖурналаРегистрации.Ошибка,
						Метаданные.ОбщиеФормы.RegistrationInImportExportTracking,
						,
						"Не удалось установить пользователя ОС """ + НовыйПользовательОС + """ у пользователя ИБ """ + ПользовательИБ.Имя + """: " + ОписаниеОшибки());
						
					СтруктураВозврата.Результат = "Error";
					СтруктураВозврата.Описание = "Failed to update an existing user";
					Возврат СтруктураВозврата;
					
				КонецПопытки;
				
				СтруктураВозврата.Результат = "AlreadyRegistered";
				Возврат СтруктураВозврата;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	// Создадим нового пользователя: пользователя в справочнике Пользователи и пользователя ИБ
	НачатьТранзакцию();
	
	// Пользователя ИБ
	ПользовательИБ = УправлениеПользователями.НайтиПользователяБД(СокрЛП(Alias));
	Если ПользовательИБ = Неопределено Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.СоздатьПользователя();
	КонецЕсли;
	ПользовательИБ.АутентификацияОС = Истина;
	ПользовательИБ.АутентификацияСтандартная = Ложь;
	ПользовательИБ.Имя = Alias;
	ПользовательИБ.ПоказыватьВСпискеВыбора = Ложь;
	ПользовательИБ.ПолноеИмя = Alias;
	ПользовательИБ.ПользовательОС = НовыйПользовательОС;
	ПользовательИБ.РежимЗапуска = РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение;
	ПользовательИБ.Роли.Добавить(Метаданные.Роли.ImportExportTracker);
	ПользовательИБ.Язык = Метаданные.Языки.Английский;
	Попытка
		ПользовательИБ.Записать();
	Исключение
			
		ОтменитьТранзакцию();
		
		ЗаписьЖурналаРегистрации(
			"Ошибка создания пользователя ИБ",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.ОбщиеФормы.RegistrationInImportExportTracking,
			,
			"Не удалось записать пользователя ИБ """ + ПользовательИБ.Имя + """: " + ОписаниеОшибки());
			
		СтруктураВозврата.Результат = "Error";
		СтруктураВозврата.Описание = "Failed to create a new user";
		Возврат СтруктураВозврата;
		
	КонецПопытки;
	
	// Элемент в справочнике Пользователи
	ПользовательСсылка = Справочники.Пользователи.НайтиПоКоду(Alias);
	Если ЗначениеЗаполнено(ПользовательСсылка) Тогда 
		ПользовательОбъект = ПользовательСсылка.ПолучитьОбъект();
		ПользовательОбъект.ПометкаУдаления = Ложь;
	иначе
		ПользовательОбъект = Справочники.Пользователи.СоздатьЭлемент();
		ПользовательОбъект.Код = Alias;
	КонецЕсли;
	
	ПользовательОбъект.Наименование = Alias;
	
	EMail = СокрЛП(Alias) + "@slb.com";
	ПользовательОбъект.EMail = EMail;
	ПользовательОбъект.КонтактнаяИнформация.Очистить();
	СтрКИ = ПользовательОбъект.КонтактнаяИнформация.Добавить();
	СтрКИ.Тип = Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты;
	СтрКИ.АдресЭП = EMail;
	СтрКИ.Представление = EMail;
	СтрКИ.Вид = Справочники.ВидыКонтактнойИнформации.НайтиПоНаименованию("E-mail",,Справочники.ВидыКонтактнойИнформации.СправочникПользователи);
	СтрКИ.ДоменноеИмяСервера = Сред(EMail, СтрНайти(EMail, "@") + 1);
	
	ПользовательОбъект.Родитель = Справочники.Пользователи.ПолучитьГруппуTrackers();
	Попытка
		ПользовательОбъект.Записать();
	Исключение
		
		ОтменитьТранзакцию();
		
		ЗаписьЖурналаРегистрации(
			"Ошибка создания пользователя",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.ОбщиеФормы.RegistrationInImportExportTracking,
			,
			"Не удалось записать нового пользователя """ + СокрЛП(ПользовательОбъект.Код) + """: " + ОписаниеОшибки());
			
		СтруктураВозврата.Результат = "Error";
		СтруктураВозврата.Описание = "Failed to create a new user";
		
		Возврат СтруктураВозврата;
		
	КонецПопытки;
	
	ГруппаДоступа = Справочники.ГруппыДоступа.RCATransportationTrackers.ПолучитьОбъект();
	СтрокаПользователи = ГруппаДоступа.Пользователи.Добавить();
	СтрокаПользователи.Пользователь = ПользовательОбъект.Ссылка;
	ГруппаДоступа.Пользователи.Свернуть("Пользователь");
	ГруппаДоступа.Записать();

	ЗафиксироватьТранзакцию();
	
	// Отправим пользователю почтовое сообщение
	СистемнаяУчетнаяЗапись = РаботаСПочтовымиСообщениями.СистемнаяУчетнаяЗапись();
		
	ПараметрыПисьма = Новый Структура;
	ПараметрыПисьма.Вставить("Кому", EMail);	
	ПараметрыПисьма.Вставить("Тема", "Welcome to RCA import tracking application");
	ПараметрыПисьма.Вставить("Тело",
		"Congratulations!
		|
		|You have successfully registered in RCA import tracking application.
		|
		|Use this link http://ru0149app35.dir.slb.com/RIET to access the system.
		|
		|Comments and suggestions are welcomed on riet-support@slb.com
		|
		|Best regards,
		|RG-Soft development team,
		|www.rg-soft.ru");
    ПараметрыПисьма.Вставить("АдресОтвета", "riet-support@slb.com");
	ПараметрыПисьма.Вставить("ТипТекста", Перечисления.ТипыТекстовЭлектронныхПисем.ПростойТекст);
	
	Попытка
		РаботаСПочтовымиСообщениями.ОтправитьПочтовоеСообщение(СистемнаяУчетнаяЗапись, ПараметрыПисьма);
	Исключение
		ЗаписьЖурналаРегистрации(
			"Ошибка отправки почтового сообщения новому пользователю RIET",
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.ОбщиеФормы.RegistrationInImportExportTracking,
			,
			"Не удалось отправить почтовое сообщение пользователю """ + ПараметрыПисьма.Кому + """: " + ОписаниеОшибки());
	КонецПопытки;
		
	СтруктураВозврата.Результат = "Registered";
	Возврат СтруктураВозврата;
	
КонецФункции

