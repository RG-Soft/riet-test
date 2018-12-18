&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если НЕ (Параметры.Свойство("Ключ") И ЗначениеЗаполнено(Объект.Ссылка)) Тогда 
		Объект.Организация = Параметры.Организация;
		Если Параметры.Свойство("НалоговыйОрган") И ЗначениеЗаполнено(Параметры.НалоговыйОрган) Тогда 
			Объект.РегистрацияВИФНС = Параметры.НалоговыйОрган;
		Иначе
			Объект.РегистрацияВИФНС = Документы.УведомлениеОСпецрежимахНалогообложения.РегистрацияВФНСОрганизации(Объект.Организация);
		КонецЕсли;
	КонецЕсли;
	
	Если РегламентированнаяОтчетностьПереопределяемый.ЭтоЮридическоеЛицо(Объект.Организация) Тогда 
		СообщениеПользователю = Новый СообщениеПользователю;
		СообщениеПользователю.Текст = "Сообщение по форме ЕНВД-4 можно создавать только для индивидуальных предпринимателей";
		СообщениеПользователю.Сообщить();
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ЭтаФорма.Заголовок = ЭтаФорма.Заголовок + " (создание)";
	КонецЕсли;
	
	Документы.УведомлениеОСпецрежимахНалогообложения.ЗагрузитьДанныеЕНВД(ЭтаФорма);
	Документы.УведомлениеОСпецрежимахНалогообложения.ЗагрузитьМакеты(ЭтаФорма, "ФормаЕНВД4Параметры");
	Документы.УведомлениеОСпецрежимахНалогообложения.СформироватьДеревоЛистовЕНВД(ЭтаФорма);
	
	РегламентированнаяОтчетностьКлиентСервер.ПриИнициализацииФормыРегламентированногоОтчета(ЭтаФорма);
	ВерсияБСП = СтандартныеПодсистемыСервер.ВерсияБиблиотеки();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТитульныйЛист(НовыйЛист) Экспорт 
	
	НовыйЛист.UID = Новый УникальныйИдентификатор;
	НовыйЛист.ДАТА_ПОДПИСИ = ТекущаяДатаСеанса(); 
	Объект.ДатаПодписи = НовыйЛист.ДАТА_ПОДПИСИ;
	
	СтрокаСведений = "ИННФЛ,ТелДом,ОГРН,ФИО,ФамилияИП,ИмяИП,ОтчествоИП";
	СведенияОбОрганизации = РегламентированнаяОтчетностьВызовСервера.ПолучитьСведенияОбОрганизации(Объект.Организация, Объект.ДатаПодписи, СтрокаСведений);
	
	НовыйЛист.ФИО_ИП = СведенияОбОрганизации.ФИО;
	НовыйЛист.П_ОГРНИП = СведенияОбОрганизации.ОГРН;
	НовыйЛист.КОД_НО = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.РегистрацияВИФНС, "Код");
	НовыйЛист.П_ИНН = СведенияОбОрганизации.ИННФЛ;
	НовыйЛист.ТЕЛЕФОН = СведенияОбОрганизации.ТелДом;
	Фамилия = СокрЛП(СведенияОбОрганизации.ФамилияИП);
	Имя = СокрЛП(СведенияОбОрганизации.ИмяИП);
	Отчество = СокрЛП(СведенияОбОрганизации.ОтчествоИП);
	
	УстановитьДанныеПоРегистрацииВИФНС();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьЛист2(НовыйЛист) Экспорт 
	
	НовыйЛист.UID = Новый УникальныйИдентификатор;
	НовыйЛист.П_ИНН1 = ТитульныйЛист[0].П_ИНН;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьДанныеПоРегистрацииВИФНС()
	
	Титульный = ТитульныйЛист[0];
	Организация = Объект.Организация;
	РегистрацияВИФНС = Объект.РегистрацияВИФНС;
	
	Титульный.КОД_НО = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(РегистрацияВИФНС, "Код");
	Представитель = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(РегистрацияВИФНС, "Представитель");
	Если ЗначениеЗаполнено(Представитель) Тогда
		Документы.УведомлениеОСпецрежимахНалогообложения.УстановитьПредставителяПоФизЛицу(Объект, Представитель, Титульный, "ИНН_ПРЕДСТАВИТЕЛЯ");
		Титульный.ПРИЗНАК_НП_ПОДВАЛ = "2";
		Титульный.ДОКУМЕНТ_ПРЕДСТАВИТЕЛЯ = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(РегистрацияВИФНС, "ДокументПредставителя");
	Иначе
		УстановитьПредставителяПоОрганизации(Титульный);
		Титульный.ПРИЗНАК_НП_ПОДВАЛ = "1";
		Титульный.ДОКУМЕНТ_ПРЕДСТАВИТЕЛЯ = "";
		Титульный.ИНН_ПРЕДСТАВИТЕЛЯ = "";
	КонецЕсли;
	
	Если ТекущийТипСтраницы = 1 Тогда
		ПредставлениеУведомления.Область("ПРИЗНАК_НП_ПОДВАЛ").Значение = Титульный.ПРИЗНАК_НП_ПОДВАЛ;
		ПредставлениеУведомления.Область("ТЕЛЕФОН").Значение = Титульный.ТЕЛЕФОН;
		ПредставлениеУведомления.Область("ДОКУМЕНТ_ПРЕДСТАВИТЕЛЯ").Значение = Титульный.ДОКУМЕНТ_ПРЕДСТАВИТЕЛЯ;
		ПредставлениеУведомления.Область("ФИО_РУКОВОДИТЕЛЯ_ПРЕДСТАВИТЕЛЯ").Значение = Титульный.ФИО_РУКОВОДИТЕЛЯ_ПРЕДСТАВИТЕЛЯ;
		ПредставлениеУведомления.Область("ИНН_ПРЕДСТАВИТЕЛЯ").Значение = Титульный.ИНН_ПРЕДСТАВИТЕЛЯ;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПредставителяПоОрганизации(Титульный)
	ДатаДанных = ?(ЗначениеЗаполнено(Объект.ДатаПодписи), Объект.ДатаПодписи, ТекущаяДата());
	СтрокаСведений = "ФамилияИП,ИмяИП,ОтчествоИП";
	СведенияОбОрганизации = РегламентированнаяОтчетностьВызовСервера.ПолучитьСведенияОбОрганизации(Объект.Организация, ДатаДанных, СтрокаСведений);
	Фамилия = СокрЛП(СведенияОбОрганизации.ФамилияИП);
	Имя = СокрЛП(СведенияОбОрганизации.ИмяИП);
	Отчество = СокрЛП(СведенияОбОрганизации.ОтчествоИП);
	Титульный.ФИО_РУКОВОДИТЕЛЯ_ПРЕДСТАВИТЕЛЯ = СокрЛП(Фамилия + " " + Имя + " " + Отчество);
	
	Объект.ПодписантФамилия = Фамилия;
	Объект.ПодписантИмя = Имя;
	Объект.ПодписантОтчество = Отчество;
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
	СохранитьДанные();
	Оповестить("Запись_УведомлениеОСпецрежимахНалогообложения",,Объект.Ссылка);
КонецПроцедуры

&НаСервере
Процедура СохранитьДанные()
	Документы.УведомлениеОСпецрежимахНалогообложения.СохранитьДанныеЕНВД(ЭтаФорма, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД4);
КонецПроцедуры

&НаКлиенте
Процедура РазделыЗаявленияПриАктивизацииСтроки(Элемент)
	
	Если ТекущийИдентификаторСтраницы = Элемент.ТекущиеДанные.UID И
		ТекущийТипСтраницы = Элемент.ТекущиеДанные.ТипСтраницы Тогда 
		
		Возврат;
	КонецЕсли;
	
	Если Элемент.ТекущиеДанные.ТипСтраницы = 0 Тогда
		УстановитьДоступностьКнопок();
		Возврат;
	КонецЕсли;
	
	ТекущийИдентификаторСтраницы = Элемент.ТекущиеДанные.UID;
	ТекущийТипСтраницы = Элемент.ТекущиеДанные.ТипСтраницы;
	СформироватьМакетНаСервере();
	УстановитьДоступностьКнопок();
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьКнопок()
	
	ТипСтраницы = Элементы.РазделыЗаявления.ТекущиеДанные.ТипСтраницы;
	
	КМенюРО = Элементы.РазделыЗаявления.КонтекстноеМеню;
	Если ТипСтраницы = 2 Тогда
		КМенюРО.Видимость = Истина;
		КМенюРО.ПодчиненныеЭлементы.РазделыЗаявленияКонтекстноеМенюДобавитьСтраницу.Доступность = Истина;
		КМенюРО.ПодчиненныеЭлементы.РазделыЗаявленияКонтекстноеМенюУдалитьСтраницу.Доступность = (СтраницыЛиста2.Количество() > 1);
	Иначе
		КМенюРО.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СформироватьМакетНаСервере()
	Документы.УведомлениеОСпецрежимахНалогообложения.СформироватьМакетНаСервере(ЭтаФорма, "ФормаЕНВД4", ПолучитьИмяОбласти(ТекущийТипСтраницы), ПолучитьИмяТаблицы(ТекущийТипСтраницы));
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьИмяОбласти(ТекущийТипСтраницы)
	
	Если ТекущийТипСтраницы = 1 Тогда
		Возврат "ТитульныйЛист";
	ИначеЕсли ТекущийТипСтраницы = 2 Тогда
		Возврат "Страница2";
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьИмяТаблицы(ТекущийТипСтраницы)
	Если ТекущийТипСтраницы = 1 Тогда
		Возврат "ТитульныйЛист";
	ИначеЕсли ТекущийТипСтраницы = 2 Тогда
		Возврат "СтраницыЛиста2";
	КонецЕсли;
	
	Возврат "";
КонецФункции

&НаКлиенте
Процедура ПредставлениеУведомленияПриИзмененииСодержимогоОбласти(Элемент, Область)
	ИмяОбласти = ПолучитьИмяОбласти(ТекущийТипСтраницы);
	Если Не ЗначениеЗаполнено(ИмяОбласти) Тогда 
		Возврат;
	КонецЕсли;
	
	ИмяТаблицы = ПолучитьИмяТаблицы(ТекущийТипСтраницы);
	ПараметрыОтбора = Новый Структура("UID", ТекущийИдентификаторСтраницы);
	Данные = ЭтаФорма[ИмяТаблицы].НайтиСтроки(ПараметрыОтбора);
	СтруктураЗаписи = Новый Структура(Область.Имя, Область.Значение);
	Если Данные.Количество() > 0 Тогда
		ЗаполнитьЗначенияСвойств(Данные[0], СтруктураЗаписи);
	КонецЕсли;
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеУведомленияВыбор(Элемент, Область, СтандартнаяОбработка)
	
	Если СтрЧислоВхождений(Область.Имя, "ДобавитьСтраницу") > 0 Тогда
		ДобавитьСтраницу(Неопределено);
	ИначеЕсли СтрЧислоВхождений(Область.Имя, "УдалитьСтраницу") > 0 Тогда
		УдалитьСтраницу(Неопределено);
	КонецЕсли;
	
	ОтборПоИмениОбласти = Новый Структура("Имя", Область.Имя);
	Поля = ПоляСОсобымПорядкомЗаполнения.НайтиСтроки(ОтборПоИмениОбласти);
	
	//Для полей адреса
	ИмяЯчейки = Лев(Область.Имя, СтрДлина(Область.Имя) - 1);
	НомерБлока = Прав(Область.Имя, 1);
	ВРЕГ_ИмяЯчейки = ВРЕГ(ИмяЯчейки);
	
	Если Поля.Количество() > 0 Тогда
		СтандартнаяОбработка = Ложь;
		НестандартнаяОбработка(Поля[0]);
		
	//форма заполнения листа адреса
	ИначеЕсли (ВРЕГ_ИмяЯчейки = "ИНДЕКС")
		ИЛИ (ВРЕГ_ИмяЯчейки = "РЕГИОН") 
		ИЛИ (ВРЕГ_ИмяЯчейки = "РАЙОН") 
		ИЛИ (ВРЕГ_ИмяЯчейки = "ГОРОД") 
		ИЛИ (ВРЕГ_ИмяЯчейки = "НАСЕЛЕННЫЙПУНКТ") 
		ИЛИ (ВРЕГ_ИмяЯчейки = "УЛИЦА")
		ИЛИ (ВРЕГ_ИмяЯчейки = "ДОМ") 
		ИЛИ (ВРЕГ_ИмяЯчейки = "КОРПУС") 
		ИЛИ (ВРЕГ_ИмяЯчейки = "КВАРТИРА") Тогда 
		
		СтандартнаяОбработка = Ложь;
		ИмяТаблицы = "СтраницыЛиста2";
		РоссийскийАдрес = Новый Соответствие;
		
		РоссийскийАдрес.Вставить("Индекс",	        ПредставлениеУведомления.Области["Индекс" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("Регион",          ПредставлениеУведомления.Области["Регион" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("КодРегиона",      ПредставлениеУведомления.Области["Регион" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("Район",           ПредставлениеУведомления.Области["Район" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("Город",           ПредставлениеУведомления.Области["Город" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("НаселенныйПункт", ПредставлениеУведомления.Области["НаселенныйПункт" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("Улица",           ПредставлениеУведомления.Области["Улица" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("Дом",             ПредставлениеУведомления.Области["Дом" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("Корпус",          ПредставлениеУведомления.Области["Корпус" + НомерБлока].Значение);
		РоссийскийАдрес.Вставить("Квартира",        ПредставлениеУведомления.Области["Квартира" + НомерБлока].Значение);
		
		Если Регионы.Количество() = 0 Тогда
			ЗаполнитьРегионыНаСервере();
		КонецЕсли;
		
		Регион = Регионы.НайтиСтроки(Новый Структура("Код", СокрЛП(РоссийскийАдрес["КодРегиона"])));
		
		Если Регион.Количество() > 0 Тогда
			
			РоссийскийАдрес["Регион"] = Регион[0].Наим;
			
		КонецЕсли;
		
		ЗначенияПолей = Новый СписокЗначений;
		
		ЗначенияПолей.Добавить(РоссийскийАдрес["Индекс"],          "Индекс");
		ЗначенияПолей.Добавить(РоссийскийАдрес["Регион"],          "Регион");
		ЗначенияПолей.Добавить(РоссийскийАдрес["КодРегиона"],      "КодРегиона");
		ЗначенияПолей.Добавить(РоссийскийАдрес["Район"],           "Район");
		ЗначенияПолей.Добавить(РоссийскийАдрес["Город"],           "Город");
		ЗначенияПолей.Добавить(РоссийскийАдрес["НаселенныйПункт"], "НаселенныйПункт");
		ЗначенияПолей.Добавить(РоссийскийАдрес["Улица"],           "Улица");
		ЗначенияПолей.Добавить(РоссийскийАдрес["Дом"],             "Дом");
		ЗначенияПолей.Добавить(РоссийскийАдрес["Корпус"],          "Корпус");
		ЗначенияПолей.Добавить(РоссийскийАдрес["Квартира"],        "Квартира");
		
		ПредставлениеАдреса = РегламентированнаяОтчетностьКлиентСервер.ПредставлениеАдресаВФормате9Запятых("643," + РоссийскийАдрес["Индекс"] + ","
		+ РоссийскийАдрес["Регион"] + ","
		+ РоссийскийАдрес["Район"] + ","
		+ РоссийскийАдрес["Город"] + ","
		+ РоссийскийАдрес["НаселенныйПункт"] + ","
		+ РоссийскийАдрес["Улица"] + ","
		+ РоссийскийАдрес["Дом"] + ","
		+ РоссийскийАдрес["Корпус"] + ","
		+ РоссийскийАдрес["Квартира"]);
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("Заголовок",               "Ввод адреса");
		ПараметрыФормы.Вставить("ЗначенияПолей", 		   ЗначенияПолей);
		ПараметрыФормы.Вставить("Представление", 		   ПредставлениеАдреса);
		ПараметрыФормы.Вставить("ВидКонтактнойИнформации", ПредопределенноеЗначение("Справочник.ВидыКонтактнойИнформации.ФактАдресОрганизации"));
		
		Если Лев(СокрЛП(ВерсияБСП), 3) = "2.1" Тогда
			Результат = ОбщегоНазначенияКлиентСервер.ОбщийМодуль("УправлениеКонтактнойИнформациейКлиент").ОткрытьФормуКонтактнойИнформацииМодально(ПараметрыФормы);
			ОбновитьАдресВТабличномДокументе(Результат, РоссийскийАдрес, НомерБлока, ИмяТаблицы);
		Иначе
			
			ДополнительныеПараметры = Новый Структура;
			ДополнительныеПараметры.Вставить("РоссийскийАдрес", РоссийскийАдрес);
			ДополнительныеПараметры.Вставить("НомерБлока", НомерБлока);
			ДополнительныеПараметры.Вставить("ИмяТаблицы", ИмяТаблицы);
			
			ТипЗначения = Тип("ОписаниеОповещения");
			ПараметрыКонструктора = Новый Массив(3);
			ПараметрыКонструктора[0] = "ОткрытьФормуКонтактнойИнформацииЗавершение";
			ПараметрыКонструктора[1] = ЭтаФорма;
			ПараметрыКонструктора[2] = ДополнительныеПараметры;
			
			Оповещение = Новый (ТипЗначения, ПараметрыКонструктора);
	
			ОбщегоНазначенияКлиентСервер.ОбщийМодуль("УправлениеКонтактнойИнформациейКлиент").ОткрытьФормуКонтактнойИнформации(ПараметрыФормы, , , , Оповещение);
			
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуКонтактнойИнформацииЗавершение(Результат, Параметры) Экспорт
	
	ОбновитьАдресВТабличномДокументе(Результат, Параметры.РоссийскийАдрес, Параметры.НомерБлока, Параметры.ИмяТаблицы);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьАдресВТабличномДокументе(Результат, РоссийскийАдрес, НомерБлока, ИмяТаблицы)
	
	Если ТипЗнч(Результат) = Тип("Структура") Тогда
		
		// Обход ошибки платформы: в веб-клиенте, в результате выполнения процедуры "СформироватьАдрес"
		// общего модуля "РегламентированнаяОтчетностьВызовСервера", не изменяются значения ключей
		// соответствия "РоссийскийАдрес", передаваемого в качестве параметра.
		РоссийскийАдрес_ = РоссийскийАдрес;
		
		РегламентированнаяОтчетностьВызовСервера.СформироватьАдрес(Результат.КонтактнаяИнформация, РоссийскийАдрес_);
		
		ПредставлениеУведомления.Области["Индекс" + НомерБлока].Значение = РоссийскийАдрес_["Индекс"];
		ПредставлениеУведомления.Области["Регион" + НомерБлока].Значение = РоссийскийАдрес_["КодРегиона"];
		ПредставлениеУведомления.Области["Район" + НомерБлока].Значение = РоссийскийАдрес_["Район"];
		ПредставлениеУведомления.Области["Город" + НомерБлока].Значение = РоссийскийАдрес_["Город"];
		ПредставлениеУведомления.Области["НаселенныйПункт" + НомерБлока].Значение = РоссийскийАдрес_["НаселенныйПункт"];
		ПредставлениеУведомления.Области["Улица" + НомерБлока].Значение = РоссийскийАдрес_["Улица"];
		ПредставлениеУведомления.Области["Дом" + НомерБлока].Значение = РоссийскийАдрес_["Дом"];
		ПредставлениеУведомления.Области["Корпус" + НомерБлока].Значение = РоссийскийАдрес_["Корпус"];
		ПредставлениеУведомления.Области["Квартира" + НомерБлока].Значение = РоссийскийАдрес_["Квартира"];
		
		ПараметрыОтбора = Новый Структура("UID", ТекущийИдентификаторСтраницы);
		Данные = ЭтаФорма[ИмяТаблицы].НайтиСтроки(ПараметрыОтбора);
		Если Данные.Количество() > 0 Тогда
			СтрокаДанных = Данные[0];
			СтрокаДанных["Индекс" + НомерБлока] = РоссийскийАдрес_["Индекс"];
			СтрокаДанных["Регион" + НомерБлока] = РоссийскийАдрес_["КодРегиона"];
			СтрокаДанных["Район" + НомерБлока] = РоссийскийАдрес_["Район"];
			СтрокаДанных["Город" + НомерБлока] = РоссийскийАдрес_["Город"];
			СтрокаДанных["НаселенныйПункт" + НомерБлока] = РоссийскийАдрес_["НаселенныйПункт"];
			СтрокаДанных["Улица" + НомерБлока] = РоссийскийАдрес_["Улица"];
			СтрокаДанных["Дом" + НомерБлока] = РоссийскийАдрес_["Дом"];
			СтрокаДанных["Корпус" + НомерБлока] = РоссийскийАдрес_["Корпус"];
			СтрокаДанных["Квартира" + НомерБлока] = РоссийскийАдрес_["Квартира"];
		КонецЕсли;
		
		Модифицированность = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьРегионыНаСервере()
	
	РегламентированнаяОтчетность.ЗаполнитьРегионы(Регионы);
	
КонецПроцедуры

&НаКлиенте
Процедура НестандартнаяОбработка(Инфо)
	Если Инфо.Обработчик = "ОбработкаДаты" Тогда
		ОбработкаДаты(Инфо);
	ИначеЕсли Инфо.Обработчик = "ОбработкаСписка" Тогда
		ОбработкаСписка(Инфо);
	ИначеЕсли Инфо.Обработчик = "ОбработкаКодаНО" Тогда
		ОбработкаКодаНО(Инфо);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаДаты(Инфо)
	
	ИмяПоля = Инфо.Имя;
	ИмяОбласти = ИмяПоля;
	Титульный = ТитульныйЛист[0];
	ДатаИсх = Неопределено;
	
	Если ЗначениеЗаполнено(Титульный[ИмяОбласти]) Тогда
		ДатаИсх = Титульный[ИмяОбласти];
	КонецЕсли;
	
	ПараметрыДаты = Новый Структура("ДатаПодписи", ДатаИсх);
	ФормаДаты = ПолучитьФорму("Документ.УведомлениеОСпецрежимахНалогообложения.Форма.ФормаВыбораДаты", ПараметрыДаты, ЭтаФорма, ЭтаФорма);
	ФормаДаты.Заголовок = ?(Инфо.Имя = "ДАТА_ПОДПИСИ", "Дата подписи", "Дата прекращения применения ЕНВД");
	ДополнительныеПараметры = Новый Структура("ИмяОбласти, Инфо, ФормаДаты", ИмяОбласти, Инфо, ФормаДаты);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаДатыЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	ФормаДаты.ОписаниеОповещенияОЗакрытии = ОписаниеОповещения;
	ФормаДаты.РежимОткрытияОкна = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
	ФормаДаты.Открыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаДатыЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ИмяОбласти = ДополнительныеПараметры.ИмяОбласти;
	Инфо = ДополнительныеПараметры.Инфо;
	ФормаДаты = ДополнительныеПараметры.ФормаДаты;
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		ДатаРезультат = ФормаДаты.Дата;
		
		Если ЗначениеЗаполнено(ДатаРезультат) Тогда 
			ПредставлениеУведомления.Область(ИмяОбласти).Значение = ДатаРезультат;
			ТитульныйЛист[0][ИмяОбласти] = ДатаРезультат;
		Иначе
			ПредставлениеУведомления.Область(ИмяОбласти).Значение = "";
			ТитульныйЛист[0][ИмяОбласти] = "";
		КонецЕсли;
		
		Если Инфо.Имя = "ДАТА_ПОДПИСИ" Тогда
			Объект.ДатаПодписи = ДатаРезультат;
			УстановитьДанныеПоРегистрацииВИФНС();
		КонецЕсли;
		
		Модифицированность = Истина;
	КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаСписка(Инфо)
	ИмяНестандартнойОбласти = Инфо.Имя;
	НазваниеСписка = Инфо.ИмяФормы;
	
	СтруктураОтбора = Новый Структура("ИмяСписка", Инфо.ИмяСписка);
	Строки = ТаблицаЗначенийПредопределенныхРеквизитов.НайтиСтроки(СтруктураОтбора);
	ЗагружаемыеКоды.Очистить();
	Для Каждого Строка Из Строки Цикл 
		НоваяСтрока = ЗагружаемыеКоды.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
	КонецЦикла;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Заголовок",          НазваниеСписка);
	ПараметрыФормы.Вставить("ТаблицаЗначений",    ЗагружаемыеКоды);
	ПараметрыФормы.Вставить("СтруктураДляПоиска", Новый Структура("Код", ПредставлениеУведомления.Области[ИмяНестандартнойОбласти].Значение));
	
	ДополнительныеПараметры = Новый Структура("ИмяНестандартнойОбласти", ИмяНестандартнойОбласти);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаСпискаЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	ОткрытьФорму("Обработка.ОбщиеОбъектыРегламентированнойОтчетности.Форма.ФормаВыбораЗначенияИзТаблицы", ПараметрыФормы, ЭтаФорма,,,, ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаСпискаЗавершение(РезультатВыбора, ДополнительныеПараметры) Экспорт
	
	ИмяНестандартнойОбласти = ДополнительныеПараметры.ИмяНестандартнойОбласти;
	
	Если РезультатВыбора = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяОбластиДоп = "";
	РезультатВыбораКод = СокрЛП(РезультатВыбора.Код);
	
	ПредставлениеУведомления.Области[ИмяНестандартнойОбласти].Значение = РезультатВыбораКод;
	ИмяОбласти = ПолучитьИмяОбласти(ТекущийТипСтраницы);
	ИмяТаблицы = ПолучитьИмяТаблицы(ТекущийТипСтраницы);
	ПараметрыОтбора = Новый Структура("UID", ТекущийИдентификаторСтраницы);
	Данные = ЭтаФорма[ИмяТаблицы].НайтиСтроки(ПараметрыОтбора);
	СтруктураЗаписи = Новый Структура(ИмяНестандартнойОбласти, РезультатВыбораКод);
	Если Данные.Количество() > 0 Тогда
		ЗаполнитьЗначенияСвойств(Данные[0], СтруктураЗаписи);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ИмяОбластиДоп) Тогда 
		СтруктураЗаписи = Новый Структура(ИмяОбластиДоп, "");
		Если Данные.Количество() > 0 Тогда
			ЗаполнитьЗначенияСвойств(Данные[0], СтруктураЗаписи);
		КонецЕсли;
	КонецЕсли;
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаКодаНО(Инфо)
	
	ПараметрыРегистрации = Новый Структура("Владелец", Объект.Организация);
	ПараметрыФормы = Новый Структура("Отбор", ПараметрыРегистрации);
	
	Форма = ПолучитьФорму("Справочник.РегистрацииВНалоговомОргане.ФормаВыбора", ПараметрыФормы, ЭтаФорма);
	ДополнительныеПараметры = Новый Структура("Инфо", Инфо);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаКодаНОЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	Форма.ОписаниеОповещенияОЗакрытии = ОписаниеОповещения;
	Форма.РежимОткрытияОкна = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
	Форма.Открыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаКодаНОЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Инфо = ДополнительныеПараметры.Инфо;
	
	Если Результат <> Неопределено Тогда 
		Объект.РегистрацияВИФНС = Результат;
		ПредставлениеУведомления.Области[Инфо.Имя].Значение = КодНалоговогоОргана();
		Модифицированность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция КодНалоговогоОргана()
	УстановитьДанныеПоРегистрацииВИФНС();
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.РегистрацияВИФНС, "Код");
КонецФункции

&НаКлиенте
Процедура ДобавитьСтраницу(Команда)
	
	Если ТекущийТипСтраницы = 2 Тогда
		ДобавитьСтраницуНаСервере();
		ПеренумероватьСтраницы();
		Модифицированность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьСтраницуНаСервере()
	Если ТекущийТипСтраницы = 2 Тогда
		КорневойУровень = РазделыЗаявления.ПолучитьЭлементы();
		СписокЛистов2 = КорневойУровень[1].ПолучитьЭлементы();
		НовыйЛист = СтраницыЛиста2.Добавить();
		ЗаполнитьЛист2(НовыйЛист);
		Лист2 = СписокЛистов2.Добавить();
		Лист2.ИндексКартинки = 1;
		Лист2.ТипСтраницы = 2;
		Лист2.Наименование = "Стр. 2";
		Лист2.UID = НовыйЛист.UID;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура УдалитьСтраницуНаСервере(UID, ТипСтраницы)
	ОтборСтрок = Новый Структура("UID", UID);
	Таблица = ЭтаФорма[ПолучитьИмяТаблицы(ТипСтраницы)];
	Строки = Таблица.НайтиСтроки(ОтборСтрок);
	Таблица.Удалить(Строки[0]);
КонецПроцедуры

&НаКлиенте
Процедура УдалитьСтраницу(Команда)

	ТекущиеДанные = Элементы.РазделыЗаявления.ТекущиеДанные;
	КопияТекущиеДанные = ТекущиеДанные;
	ТекущиеДанные = ТекущиеДанные.ПолучитьРодителя();
	
	Если ТекущиеДанные = Неопределено Или ТекущиеДанные.ПолучитьЭлементы().Количество() = 1 Тогда
		Возврат;
	КонецЕсли;
	УдалитьСтраницуНаСервере(КопияТекущиеДанные.UID, КопияТекущиеДанные.ТипСтраницы);
	ТекущиеДанные.ПолучитьЭлементы().Удалить(ТекущиеДанные.ПолучитьЭлементы().Индекс(КопияТекущиеДанные));
	ПеренумероватьСтраницы();
	Модифицированность = Истина;

КонецПроцедуры

&НаКлиенте
Процедура ПеренумероватьСтраницы()
	Листы = РазделыЗаявления.ПолучитьЭлементы()[1].ПолучитьЭлементы();
	Номер = 1;
	Для Каждого Лист Из Листы Цикл 
		Лист.Наименование = "Стр. "+Номер;
		Номер = Номер + 1;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ПриЗакрытииНаСервере()
	СохранитьДанные();
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	Если Модифицированность Тогда
		ПриЗакрытииНаСервере();
	КонецЕсли;
	Оповестить("Запись_УведомлениеОСпецрежимахНалогообложения",,Объект.Ссылка);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если Модифицированность Тогда
		Отказ = Истина;
		Оповещение = Новый ОписаниеОповещения("ПередЗакрытиемЗавершение", ЭтотОбъект);
		ТекстВопроса = ВернутьСтр("ru='Заявление изменено. Сохранить изменения?'");
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНетОтмена, , КодВозвратаДиалога.Да);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытиемЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		СохранитьДанные();
		Закрыть();
	ИначеЕсли Ответ = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СформироватьXMLНаСервере(УникальныйИдентификатор)
	СохранитьДанные();
	Документ = ДанныеФормыВЗначение(Объект, Тип("ДокументОбъект.УведомлениеОСпецрежимахНалогообложения"));
	Возврат Документ.ВыгрузитьДокумент(УникальныйИдентификатор);
КонецФункции

&НаКлиенте
Процедура СформироватьXML(Команда)
	
	ВыгружаемыеДанные = СформироватьXMLНаСервере(УникальныйИдентификатор);
	Если ВыгружаемыеДанные <> Неопределено Тогда 
		РегламентированнаяОтчетностьКлиент.ВыгрузитьФайлы(ВыгружаемыеДанные);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СформироватьПечатнуюФорму()
	СохранитьДанные();
	Документ = ДанныеФормыВЗначение(Объект, Тип("ДокументОбъект.УведомлениеОСпецрежимахНалогообложения"));
	Возврат Документ.ПечатьСразу();
КонецФункции

&НаКлиенте
Процедура ПечатьУведомления(Команда)
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда 
		ТекстВопроса = "Заявление изменено. Перед печатью необходимо сохранить изменения. Сохранить изменения?";
		ОписаниеОповещения = Новый ОписаниеОповещения("ПечатьУведомленияЗавершение", ЭтотОбъект);
		ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет, 0);
	Иначе
		ПФ = СформироватьПечатнуюФорму();
		Если ПФ <> Неопределено Тогда 
			ПФ.Напечатать(РежимИспользованияДиалогаПечати.НеИспользовать);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПечатьУведомленияЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		ПФ = СформироватьПечатнуюФорму();
		Если ПФ <> Неопределено Тогда 
			ПФ.Напечатать(РежимИспользованияДиалогаПечати.НеИспользовать);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПредварительныйПросмотр(Команда)
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ТекстВопроса = "Заявление изменено. Перед печатью необходимо сохранить изменения. Сохранить изменения?";
		ОписаниеОповещения = Новый ОписаниеОповещения("ПредварительныйПросмотрЗавершение", ЭтотОбъект);
		ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет, 0);
		Возврат;
	ИначеЕсли Модифицированность Тогда 
		СохранитьДанные();
	КонецЕсли;
	
	МассивПечати = Новый Массив;
	МассивПечати.Добавить(Объект.Ссылка);
	УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(
		"Документ.УведомлениеОСпецрежимахНалогообложения",
		"Уведомление", МассивПечати, Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредварительныйПросмотрЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		СохранитьДанные();
		МассивПечати = Новый Массив;
		МассивПечати.Добавить(Объект.Ссылка);
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(
			"Документ.УведомлениеОСпецрежимахНалогообложения",
			"Уведомление", МассивПечати, Неопределено);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Элементы.РазделыЗаявления.НачальноеОтображениеДерева = НачальноеОтображениеДерева.РаскрыватьВсеУровни;
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	Оповестить("Запись_УведомлениеОСпецрежимахНалогообложения", ПараметрыЗаписи, Объект.Ссылка);
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	СохранитьДанные();
	Оповестить("Запись_УведомлениеОСпецрежимахНалогообложения",,Объект.Ссылка);
	Закрыть(Неопределено);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Отправка в ФНС

&НаКлиенте
Процедура ОтправитьВКонтролирующийОрган(Команда)
	
	РегламентированнаяОтчетностьКлиент.ПриНажатииНаКнопкуОтправкиВКонтролирующийОрган(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьВИнтернете(Команда)
	
	РегламентированнаяОтчетностьКлиент.ПроверитьВИнтернете(ЭтаФорма);
	
КонецПроцедуры

#Область ПанельОтправкиВКонтролирующиеОрганы

&НаКлиенте
Процедура ОбновитьОтправку(Команда)
	ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ОбновитьОтправкуИзПанелиОтправки(ЭтаФорма, "ФНС");
КонецПроцедуры

&НаКлиенте
Процедура ГиперссылкаПротоколНажатие(Элемент)
	ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ОткрытьПротоколИзПанелиОтправки(ЭтаФорма, "ФНС");
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьНеотправленноеИзвещение(Команда)
	ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ОтправитьНеотправленноеИзвещениеИзПанелиОтправки(ЭтаФорма, "ФНС");
КонецПроцедуры

&НаКлиенте
Процедура ЭтапыОтправкиНажатие(Элемент)
	ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ОткрытьСостояниеОтправкиИзПанелиОтправки(ЭтаФорма, "ФНС");
КонецПроцедуры

&НаКлиенте
Процедура КритическиеОшибкиОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ОткрытьКритическиеОшибкиИзПанелиОтправки(ЭтаФорма, "ФНС");
КонецПроцедуры

#КонецОбласти