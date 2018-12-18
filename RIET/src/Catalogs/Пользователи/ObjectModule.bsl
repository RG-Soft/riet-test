#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
#КонецЕсли

Перем ПараметрыОбработкиПользователяИБ; // Параметры, заполняемые при обработке пользователя ИБ.
                                        // Используются в обработчике события ПриЗаписи.

Перем ЭтоНовый; // Показывает, что был записан новый объект.

//////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	  		
	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Alias"" is empty!",
			ЭтотОбъект, "Код", , Отказ);
		Возврат;
	КонецЕсли;
	          		
	Недействителен = ПометкаУдаления;
	
	ДозаполнитьРеквизиты();

	ПользователиСлужебный.НачатьОбработкуПользователяИБ(ЭтотОбъект, ПараметрыОбработкиПользователяИБ);
	
	//{ RGS EKoshkina 06.11.2015 10:48:12 - S-I-0001345
	ТекПользовательБД = УправлениеПользователями.НайтиПользователяБД(СокрЛП(Код));
	Если ТекПользовательБД <> Неопределено Тогда
		ИдентификаторПользователяИБ = ТекПользовательБД.УникальныйИдентификатор;
	КонецЕсли;
	//} RGS EKoshkina 06.11.2015 10:48:12 - S-I-0001345
	
	//{RG-Soft добавила Петроченко Н.Н.
	Если Не ПометкаУдаления Тогда 
		УстановитьПривилегированныйРежим(Истина);
		
		//{ RGS AArsentev 07.03.2017 - S-I-0002661
		//ПользовательИБ = УправлениеПользователями.НайтиПользователяБД(ДополнительныеСвойства.Код);
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(ИдентификаторПользователяИБ);
		Если ПользовательИБ = Неопределено Тогда
			ПользовательИБ = УправлениеПользователями.НайтиПользователяБД(ДополнительныеСвойства.Код);
		КонецЕсли;
		//} RGS AArsentev 07.03.2017 - S-I-0002661
		
		Если ПользовательИБ <> Неопределено 
			//добавила Федотова Л., РГ-Софт, 13.07.16, вопрос SLI-0006602
			//И (РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() ИЛИ РГСофтСерверПовтИспСеанс.ЭтоRIET_test())
			//
			Тогда
			ПользовательИБ.ПользовательОС = "\\" + "dir" + "\" + СокрЛП(Код);
			ПользовательИБ.АутентификацияОС = Истина;
			// { RGS VChaplygin 13.04.2018 19:03:28 - S-I-0005054
			//ПользовательИБ.АутентификацияСтандартная = Ложь;
			Если НЕ (ПользовательИБ.Роли.Содержит(Метаданные.Роли.ImportExportBroker) И ЗначениеЗаполнено(CCA) И ПользовательИБ.ПарольУстановлен) Тогда
				ПользовательИБ.АутентификацияСтандартная = Ложь;
			КонецЕсли;
			// } RGS VChaplygin 13.04.2018 19:03:30 - S-I-0005054
			ПользовательИБ.ПоказыватьВСпискеВыбора = Ложь;
			ПользовательИБ.РежимЗапуска = РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение;
			ПользовательИБ.Имя = СокрЛП(Код);
			ПользовательИБ.ПолноеИмя = СокрЛП(Код);
			ПользовательИБ.Записать();
		КонецЕсли;
	КонецЕсли;	//RG-Soft конец добавления}
		
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	//{закомментировала Петроченко Н.Н. - с 25.12.2016 используется авторегистрация пользователей в мониторе 
	//Если ЭтоНовый Тогда     
	//	СоздатьПарольИСообщитьВМонитор(Отказ);
	//КонецЕсли; }

	Если ДополнительныеСвойства.Свойство("ГруппаНовогоПользователя")
		И ЗначениеЗаполнено(ДополнительныеСвойства.ГруппаНовогоПользователя) Тогда
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.ГруппыПользователей");
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();
		
		ОбъектГруппы = ДополнительныеСвойства.ГруппаНовогоПользователя.ПолучитьОбъект();
		ОбъектГруппы.Состав.Добавить().Пользователь = Ссылка;
		ОбъектГруппы.Записать();
	КонецЕсли;
	
	 //Обновление состава автоматической группы "Все пользователи".
	УчастникиИзменений = Новый Соответствие;
	ИзмененныеГруппы   = Новый Соответствие;
	
	ПользователиСлужебный.ОбновитьСоставыГруппПользователей(
		Справочники.ГруппыПользователей.ВсеПользователи, Ссылка, УчастникиИзменений, ИзмененныеГруппы);
	
	ПользователиСлужебный.ОбновитьИспользуемостьСоставовГруппПользователей(
		Ссылка, УчастникиИзменений, ИзмененныеГруппы);
	
	ПользователиСлужебный.ЗавершитьОбработкуПользователяИБ(
		ЭтотОбъект, ПараметрыОбработкиПользователяИБ);
	
	ПользователиСлужебный.ПослеОбновленияСоставовГруппПользователей(
		УчастникиИзменений, ИзмененныеГруппы);
	
	ПользователиСлужебный.ВключитьЗаданиеКонтрольАктивностиПользователейПриНеобходимости(Ссылка);
	
	ИнтеграцияСтандартныхПодсистем.ПослеДобавленияИзмененияПользователяИлиГруппы(Ссылка, ЭтоНовый);
	
	// { RG-Soft начало добавления - Петроченко Н.Н.
	Если Не Пользователи.ЭтоПолноправныйПользователь(Ссылка)
		И УправлениеДоступом.ЕстьРоль("ImportExportBroker", , Ссылка) 
		И Не ЗначениеЗаполнено(CCA) Тогда 
	    ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""CCA"" is empty!",
			ЭтотОбъект, "CCA", , Отказ);
	КонецЕсли; // } RG-Soft - конец добавления 
	
КонецПроцедуры

Процедура СоздатьПарольИСообщитьВМонитор(Отказ)
	
	//с 25.12.2016 используется авторегистрация пользователей в мониторе
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Не РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Возврат;
	КонецЕсли;
	
	СистемнаяУчетнаяЗапись = РаботаСПочтовымиСообщениями.СистемнаяУчетнаяЗапись();
		
	ПараметрыПисьма = Новый Структура;
	ПараметрыПисьма.Вставить("Кому", Константы.АдресатыПолученияНовыхПользователейМонитора.Получить());
	ПараметрыПисьма.Вставить("Тема", "Новый пользователь в базе RIET SLB Import/Export!");
	ПараметрыПисьма.Вставить("Тело",
		"В рабочей базе RIET SLB Import/Export создан новый пользователь.
		|Необходимо добавить его в монитор сопровождения и настроить уведомления:
		|логин - \\dir\" + СокрЛП(Код) + ";
		|пароль - \\dir\" + СокрЛП(Код) + "pass!;
		|Email - " + СокрЛП(Email) + ".");
	
	РаботаСПочтовымиСообщениями.ОтправитьПочтовоеСообщение(СистемнаяУчетнаяЗапись, ПараметрыПисьма);
		
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ОбщиеДействияПередУдалениемВОбычномРежимеИПриОбменеДанными();
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	ДополнительныеСвойства.Вставить("ЗначениеКопирования", ОбъектКопирования.Ссылка);
	
	ИдентификаторПользователяИБ = Неопределено;
	ИдентификаторПользователяСервиса = Неопределено;
	Подготовлен = Ложь;
	
	//КонтактнаяИнформация.Очистить();
	Комментарий = "";
	
КонецПроцедуры


#Область СлужебныеПроцедурыИФункции

// Только для внутреннего использования.
Процедура ОбщиеДействияПередУдалениемВОбычномРежимеИПриОбменеДанными() Экспорт
	
	// Требуется удалить пользователя ИБ, иначе он попадет в список ошибок в форме ПользователиИБ,
	// кроме того, вход под этим пользователем ИБ приведет к ошибке.
	
	ОписаниеПользователяИБ = Новый Структура;
	ОписаниеПользователяИБ.Вставить("Действие", "Удалить");
	ДополнительныеСвойства.Вставить("ОписаниеПользователяИБ", ОписаниеПользователяИБ);
	
	ПользователиСлужебный.НачатьОбработкуПользователяИБ(ЭтотОбъект, ПараметрыОбработкиПользователяИБ, Истина);
	ПользователиСлужебный.ЗавершитьОбработкуПользователяИБ(ЭтотОбъект, ПараметрыОбработкиПользователяИБ);
	
КонецПроцедуры

Процедура ДозаполнитьРеквизиты()
	
	ЭтоНовый = ЭтоНовый();
	ДополнительныеСвойства.Вставить("ЭтоНовый", ЭтоНовый);
	
	Если ЭтоНовый Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;

	Если СтрДлина(СокрЛП(Код)) > 2 Тогда 
		Код = ВРег(Сред(СокрЛП(Код), 1, 2)) + НРег(Сред(СокрЛП(Код), 3));
	иначе
		Код = ВРег(СокрЛП(Код));
	КонецЕсли;

	ДополнительныеСвойства.Вставить("Код", СокрЛП(Код));

	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() ИЛИ РГСофтСерверПовтИспСеанс.ЭтоRIET_test() Тогда 
		Наименование = СокрЛП(Код);
	иначе
		//Добавила условие Федотова Л., РГ-Софт, 10.06.16, вопрос SFA-0000070
		Если НЕ ЗначениеЗаполнено(Наименование) Тогда
			Наименование = СокрЛП(Код);
		КонецЕсли; 
	КонецЕсли;
	
	// для поддержки предыдущего использования emails
	Для Каждого СтрокаКонтактнойИнформации из КонтактнаяИнформация Цикл 
		Если СтрокаКонтактнойИнформации.Тип = Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты Тогда 
			EMail = СтрокаКонтактнойИнформации.Представление;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры


#КонецОбласти


