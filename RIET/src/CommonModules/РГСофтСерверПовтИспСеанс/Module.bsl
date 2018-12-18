
Функция ЗначениеРеквизитаОбъекта(Ссылка, ИмяРеквизита) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Ссылка) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, ИмяРеквизита);
	
КонецФункции

Функция ЗначенияРеквизитовОбъекта(Ссылка, Реквизиты) Экспорт
	
	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, Реквизиты);
	
КонецФункции

Функция ПолучитьВыборку(ТипОбъекта, ИмяОбъекта, ВыбираемыеПоля, СтруктураОтборов=Неопределено, ПривилегированныйРежим=Ложь) Экспорт
	
	Возврат РГСофт.ПолучитьВыборку(ТипОбъекта, ИмяОбъекта, ВыбираемыеПоля, СтруктураОтборов, ПривилегированныйРежим);
	
КонецФункции

Функция НайтиСсылку(ТипОбъекта, ИмяОбъекта, ПолеПоиска, ЗначениеПоля) Экспорт
	
	Возврат РГСофт.НайтиСсылку(ТипОбъекта, ИмяОбъекта, ПолеПоиска, ЗначениеПоля);
	
КонецФункции

Функция ПолучитьЗначениеПоУмолчанию(Пользователь, Настройка) Экспорт
	
	Возврат УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(Пользователь, Настройка);
	
КонецФункции

Функция ПолучитьПараметрыПечатиСФНаСервере(Пользователь) Экспорт 
	
	ПараметрыПечати = Новый Структура;
	ПараметрыПечати.Вставить("ВыводитьSIRВСФ", УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(Пользователь, "ВыводитьSIRВСФ"));
	ПараметрыПечати.Вставить("ВыводитьДанныеОСкважинеВСФ", УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(Пользователь, "ВыводитьДанныеОСкважинеВСФ"));
	ПараметрыПечати.Вставить("ВыводитьЗаголовокСФ", УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(Пользователь, "ВыводитьЗаголовокСФ"));
	ПараметрыПечати.Вставить("ВыводитьЗаказНарядВСФ", УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(Пользователь, "ВыводитьЗаказНарядВСФ"));
	ПараметрыПечати.Вставить("ВыводитьРасчетныйСчетВСФ", УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(Пользователь, "ВыводитьРасчетныйСчетВСФ"));
	ПараметрыПечати.Вставить("ВыводитьДанныеОДоговореВСФ", УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(Пользователь, "ВыводитьДанныеОДоговореВСФ"));
	ПараметрыПечати.Вставить("ВыводитьНомерАкта", УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(Пользователь, "ВыводитьНомерАкта"));
	//добавила Федотова Л., РГ-Софт, 10.08.10 ->
	ПараметрыПечати.Вставить("ВыводитьСкидку", Ложь);
	ПараметрыПечати.Вставить("ПроцентСкидки", 20);
	//<-
	ПараметрыПечати.Вставить("ДоговорВШапке", Ложь);
	Возврат ПараметрыПечати;
	
КонецФункции

Функция ЭтоProductionБаза() Экспорт 
	
	// Определение продакшн база или нет основывается на строке соединения
	
	ИмяПродакшнСервера = "ru0149app35";
	IPПродакшнСервера = "134.32.36.109";
	ПродакшнПорт = "1541";
	ИмяПродакшнБазы = "RIET";
		
	ПодстрокиСоединения = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(
									СтрокаСоединенияИнформационнойБазы(), ";");
	ИмяСервера = СтроковыеФункцииКлиентСервер.СократитьДвойныеКавычки(Сред(ПодстрокиСоединения[0], 7));
	ИмяИБ = СтроковыеФункцииКлиентСервер.СократитьДвойныеКавычки(Сред(ПодстрокиСоединения[1], 6));
	
	// Проверяем имя базы
	Если ВРег(ИмяИБ) <> ИмяПродакшнБазы Тогда 
		Возврат Ложь;
	КонецЕсли;

	// Проверяем продашкн порт
	ПозицияДвоеточия = СтрНайти(ИмяСервера, ":");
	Если ПозицияДвоеточия > 0 Тогда 
		Порт = Сред(ИмяСервера, (ПозицияДвоеточия+1));
	Иначе
		Порт = "1541";
	КонецЕсли;
	
	Если СокрЛП(Порт) <> ПродакшнПорт Тогда 
		Возврат Ложь;
	КонецЕсли;

	// Если база прописана на локальном компьютере - проверяем его имя
	Если (Найти(НРег(ИмяСервера), "localhost") > 0 
		ИЛИ СтрНайти(ИмяСервера, "127.0.0.1") > 0)
		И СтрНайти(НРег(ИмяКомпьютера()), ИмяПродакшнСервера) > 0 Тогда 
		Возврат Истина;
	КонецЕсли;
	
	// Проверяем имя сервера
	Если СтрНайти(НРег(ИмяСервера), ИмяПродакшнСервера) = 0 
		И СтрНайти(ИмяСервера, IPПродакшнСервера) = 0 Тогда 
		Возврат Ложь;
	КонецЕсли;

	Возврат Истина;
	
КонецФункции

// { RGS LFedotova 24.01.2018 22:11:00 - вопрос SLI-0007472
Функция ЭтоProductionБазаLogelco() Экспорт 
	
	// Определение продакшн база или нет основывается на строке соединения
	
	ИмяПродакшнСервера = "ru0149app14";
	IPПродакшнСервера = "134.32.36.23"; 
	ПродакшнПорт = "7541";
	ИмяПродакшнБазы = "SLI";
		
	ПодстрокиСоединения = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(
									СтрокаСоединенияИнформационнойБазы(), ";");
	ИмяСервера = СтроковыеФункцииКлиентСервер.СократитьДвойныеКавычки(Сред(ПодстрокиСоединения[0], 7));
	ИмяИБ = СтроковыеФункцииКлиентСервер.СократитьДвойныеКавычки(Сред(ПодстрокиСоединения[1], 6));
	
	// Проверяем имя базы
	Если ВРег(ИмяИБ) <> ИмяПродакшнБазы Тогда 
		Возврат Ложь;
	КонецЕсли;

	// Проверяем продашкн порт
	ПозицияДвоеточия = СтрНайти(ИмяСервера, ":");
	Если ПозицияДвоеточия > 0 Тогда 
		Порт = Сред(ИмяСервера, (ПозицияДвоеточия+1));
	Иначе
		Порт = "1541";
	КонецЕсли;
	
	Если СокрЛП(Порт) <> ПродакшнПорт Тогда 
		Возврат Ложь;
	КонецЕсли;

	// Если база прописана на локальном компьютере - проверяем его имя
	Если (Найти(НРег(ИмяСервера), "localhost") > 0 
		ИЛИ СтрНайти(ИмяСервера, "127.0.0.1") > 0)
		И СтрНайти(НРег(ИмяКомпьютера()), ИмяПродакшнСервера) > 0 Тогда 
		Возврат Истина;
	КонецЕсли;
	
	// Проверяем имя сервера
	Если СтрНайти(НРег(ИмяСервера), ИмяПродакшнСервера) = 0 
		И СтрНайти(ИмяСервера, IPПродакшнСервера) = 0 Тогда 
		Возврат Ложь;
	КонецЕсли;

	Возврат Истина;
	
КонецФункции
// } RGS LFedotova 24.01.2018 22:11:32 - вопрос SLI-0007472

// { RGS LFedotova 20.09.2016 16:00:26 - вопрос SLI-0006800
Функция ЭтоLogelco() Экспорт 
	
	ПодстрокиСоединения = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(
									СтрокаСоединенияИнформационнойБазы(), ";");
	ИмяИБ = СтроковыеФункцииКлиентСервер.СократитьДвойныеКавычки(Сред(ПодстрокиСоединения[1], 6));
	
	// Проверяем имя базы
	Если ИмяИБ = "SLI" ИЛИ ИмяИБ = "test_Liudmila" ИЛИ ИмяИБ = "test_Logelco" Тогда 
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции
// } RGS LFedotova 20.09.2016 16:01:04 - вопрос SLI-0006800

Функция ЭтоLogelco_test() Экспорт 
	
	ПодстрокиСоединения = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(
									СтрокаСоединенияИнформационнойБазы(), ";");
	ИмяИБ = СтроковыеФункцииКлиентСервер.СократитьДвойныеКавычки(Сред(ПодстрокиСоединения[1], 6));
	
	// Проверяем имя базы
	Если ИмяИБ = "test_Liudmila" ИЛИ ИмяИБ = "test_Logelco" ИЛИ ИмяИБ = "RIET_test5" Тогда 
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

Функция ЭтоRIET_test() Экспорт 
	
	// Определение продакшн база или нет основывается на строке соединения
	
	ИмяПродакшнСервера = "ru0149app35";
	IPПродакшнСервера = "134.32.36.109";
	ПродакшнПорт = "2041";
	ИмяПродакшнБазы = "RIET_test";
		
	ПодстрокиСоединения = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(
									СтрокаСоединенияИнформационнойБазы(), ";");
	ИмяСервера = СтроковыеФункцииКлиентСервер.СократитьДвойныеКавычки(Сред(ПодстрокиСоединения[0], 7));
	ИмяИБ = СтроковыеФункцииКлиентСервер.СократитьДвойныеКавычки(Сред(ПодстрокиСоединения[1], 6));
	
	// Проверяем имя базы
	Если ИмяИБ <> ИмяПродакшнБазы Тогда 
		Возврат Ложь;
	КонецЕсли;

	// Проверяем продашкн порт
	ПозицияДвоеточия = СтрНайти(ИмяСервера, ":");
	Если ПозицияДвоеточия > 0 Тогда 
		Порт = Сред(ИмяСервера, (ПозицияДвоеточия+1));
	Иначе
		Порт = "2041";
	КонецЕсли;
	
	Если СокрЛП(Порт) <> ПродакшнПорт Тогда 
		Возврат Ложь;
	КонецЕсли;

	// Если база прописана на локальном компьютере - проверяем его имя
	Если (Найти(НРег(ИмяСервера), "localhost") > 0 
		ИЛИ СтрНайти(ИмяСервера, "127.0.0.1") > 0)
		И СтрНайти(НРег(ИмяКомпьютера()), ИмяПродакшнСервера) > 0 Тогда 
		Возврат Истина;
	КонецЕсли;
	
	// Проверяем имя сервера
	Если СтрНайти(НРег(ИмяСервера), ИмяПродакшнСервера) = 0 
		И СтрНайти(ИмяСервера, IPПродакшнСервера) = 0 Тогда 
		Возврат Ложь;
	КонецЕсли;

	Возврат Истина;
	
КонецФункции

Функция ПолучитьАдресБазы() Экспорт
	
	Если ЭтоProductionБаза() Тогда 
		Возврат "http://ru0149app35.dir.slb.com/RIET/#";
	Иначе
		Возврат "http://ru0149app35.dir.slb.com/RIET_test/#";
 	КонецЕсли; 	
	
КонецФункции

Функция ЭтоПользовательШлюмберже(Пользователь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	РеквизитыПользователя = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Пользователь, "Код, CCA");
	
	Возврат УправлениеПользователями.НайтиПользователяБД(СокрЛП(РеквизитыПользователя.Код)) <> Неопределено
		И Не ЗначениеЗаполнено(РеквизитыПользователя.CCA);
	
КонецФункции
	
Функция ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Экспорт 
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат ПараметрыСеанса.ShowNamesAndDescriptionsRUS;
	
КонецФункции

Функция ПолучитьМассивSpecialists() Экспорт 
	
	УстановитьПривилегированныйРежим(Истина);

	РольSpecialist = Метаданные.Роли.LocalDistributionSpecialist_ForNonLawsonCompanies;
	
	МассивAliasSpecialists = Новый Массив;
	МассивПользователейИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого ПользовательИБ Из МассивПользователейИБ Цикл
		
		Если ПользовательИБ.Роли.Содержит(РольSpecialist) Тогда 
			МассивAliasSpecialists.Добавить(ПользовательИБ.Имя);
		КонецЕсли;
		
	КонецЦикла;	
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивAliasSpecialists", МассивAliasSpecialists);
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Пользователи.Ссылка КАК User,
		|	ВЫРАЗИТЬ(Пользователи.Код КАК СТРОКА(50)) КАК UserAlias
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	Пользователи.Код В(&МассивAliasSpecialists)
		|	И НЕ Пользователи.ЭтоГруппа
		|	И НЕ Пользователи.ПометкаУдаления";
				   
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("User"); 
	
КонецФункции

Функция ПолучитьМассивCompaniesWithSettings() Экспорт 
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекДата", ТекущаяДата());	
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.Company КАК Company
		|ИЗ
		|	РегистрСведений.LocalDistributionSettingsForNonLawsonCompanies.СрезПоследних(&ТекДата, ) КАК LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних";
				   
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Company"); 
	
КонецФункции

Функция ПолучитьМассивOperators() Экспорт 
	
	УстановитьПривилегированныйРежим(Истина);

	РольOperator = Метаданные.Роли.LocalDistributionOperator_ForNonLawsonCompanies;
	
	МассивAliasOperators = Новый Массив;
	МассивПользователейИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	Для Каждого ПользовательИБ Из МассивПользователейИБ Цикл
		
		Если ПользовательИБ.Роли.Содержит(РольOperator) Тогда 
			МассивAliasOperators.Добавить(ПользовательИБ.Имя);
		КонецЕсли;
		
	КонецЦикла;	
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивAliasOperators", МассивAliasOperators);
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Пользователи.Ссылка КАК User,
		|	ВЫРАЗИТЬ(Пользователи.Код КАК СТРОКА(50)) КАК UserAlias
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	Пользователи.Код В(&МассивAliasOperators)
		|	И НЕ Пользователи.ЭтоГруппа
		|	И НЕ Пользователи.ПометкаУдаления";
				   
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("User"); 
	
КонецФункции

Функция ПолучитьМассивВалютДляTripNonLawson() Экспорт 
	
	МассивКодов = Новый Массив();
	МассивКодов.Добавить("643");
	МассивКодов.Добавить("840");
	МассивКодов.Добавить("398");
	МассивКодов.Добавить("944");
	МассивКодов.Добавить("978");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивКодов", МассивКодов);
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Валюты.Ссылка КАК Валюта
		|ИЗ
		|	Справочник.Валюты КАК Валюты
		|ГДЕ
		|	Валюты.Код В(&МассивКодов)";
				   
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Валюта"); 
	
КонецФункции

Функция ПолучитьМассивLocalDistributionMOT() Экспорт
	
	//AIR, TRUCK, RAIL, SEA, CURIER
	МассивMOT = Новый Массив;
	
	МассивMOT.Добавить(Справочники.MOTs.AIR);
	МассивMOT.Добавить(Справочники.MOTs.COURIER);
	МассивMOT.Добавить(Справочники.MOTs.НайтиПоКоду("TRUCK"));
	МассивMOT.Добавить(Справочники.MOTs.НайтиПоКоду("RAIL"));
	МассивMOT.Добавить(Справочники.MOTs.НайтиПоКоду("SEA"));
	
	Возврат МассивMOT;
	
КонецФункции

// { RGS AArsentev S-I-0003275 22.06.2017 11:08:55 
// { RGS ASeryakov S-I-0005001 10.04.2018 12:00:00
//Функция ЭтоDGF(User) Экспорт
Функция ЭтоDGForDHL(User) Экспорт
// } RGS ASeryakov S-I-0005001 10.04.2018 12:00:00
	
	ЭтоDGF = Ложь;
	Попытка
		CCA = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(User, "CCA");
		// { RGS ASeryakov S-I-0005001 10.04.2018 12:00:00
		//Если ЗначениеЗаполнено(CCA) И СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(CCA, "Код")) = "DGF" Тогда
		Если ЗначениеЗаполнено(CCA) И (СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(CCA, "Код")) = "DGF"
			ИЛИ СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(CCA, "Код")) = "DHL"
				// { RGS AArsentev 05.06.2018
				ИЛИ СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(CCA, "Код")) = "GLB"
				ИЛИ СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(CCA, "Код")) = "FML")
				// } RGS AArsentev 05.06.2018
			Тогда
			// { RGS ASeryakov S-I-0005001 10.04.2018 12:00:00
			ЭтоDGF = Истина;	
		КонецЕсли;
		Возврат ЭтоDGF;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции // } RGS AArsentev S-I-0003275 22.06.2017 11:08:55 


///////////////////////////////////////////////////////////////////////////
// УДАЛИТЬ

Функция ПолучитьЗначениеРеквизита(Ссылка, ИмяРеквизита) Экспорт
	
	// Устаревшее название для функции ЗначениеРеквизитаОбъекта
	
	Возврат ЗначениеРеквизитаОбъекта(Ссылка, ИмяРеквизита);
	
КонецФункции
