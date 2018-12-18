&НаКлиенте
Перем ПараметрыОбработчикаОжидания;

&НаКлиенте
Перем ИнтервалПроверкиРезультата;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьТекстЗаголовка(Форма)

	Отчет = Форма.Отчет;

	ЗаголовокОтчета = НСтр("ru='Книга покупок'")
					+ БухгалтерскиеОтчетыКлиентСервер.ПолучитьПредставлениеПериода(Отчет.НачалоПериода,
																				 Отчет.КонецПериода);

	Если ЗначениеЗаполнено(Отчет.Организация) И Форма.ИспользуетсяНесколькоОрганизаций Тогда
		ЗаголовокОтчета = ЗаголовокОтчета
						+ " "
						+ БухгалтерскиеОтчетыВызовСервераПовтИсп.ПолучитьТекстОрганизация(Отчет.Организация,
																			Отчет.ВключатьОбособленныеПодразделения);
	КонецЕсли;

	Форма.Заголовок = ЗаголовокОтчета;

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)

	Отчет    = Форма.Отчет;
	Элементы = Форма.Элементы;

	Элементы.ДополнительныеЛистыЗаТекущийПериод.Доступность = Отчет.ФормироватьДополнительныеЛисты;
	Элементы.ВыводитьТолькоДопЛисты.Доступность             = Отчет.ФормироватьДополнительныеЛисты;

КонецПроцедуры

&НаСервере
Функция СформироватьОтчетНаСервере()

	Если Не ПроверитьЗаполнение() Тогда
		Возврат Новый Структура("ЗаданиеВыполнено", Истина);
	КонецЕсли;
	
	Если НЕ ИспользованиеПроверкиВозможно Тогда
		ИспользованиеПроверкиВозможно = ПроверкаКонтрагентовВызовСервера.ИспользованиеПроверкиВозможно();
	КонецЕсли;
	
	Если ИспользованиеПроверкиВозможно Тогда
		ЕстьДоступКВебСервисуФНС = ПроверкаКонтрагентов.ЕстьДоступКВебСервисуФНС();
		ВыведеныВсеСтроки = Истина;
		ПереключательРежимаОтображения = "Все";
		НедействующиеКонтрагенты.Очистить();
	КонецЕсли;

	ИБФайловая = ОбщегоНазначения.ИнформационнаяБазаФайловая();
	
	ДлительныеОперации.ОтменитьВыполнениеЗадания(ИдентификаторЗадания);
	
	ИдентификаторЗадания = Неопределено;
	
	ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(Элементы.Результат, "НеИспользовать");
	
	ПараметрыОтчета = ПодготовитьПараметрыОтчета(Истина);
	
	Если ИБФайловая Тогда
		АдресХранилища = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
		УчетНДСПереопределяемый.ПодготовитьПараметрыКнигиПокупок(ПараметрыОтчета, АдресХранилища);
		РезультатВыполнения = Новый Структура("ЗаданиеВыполнено", Истина);
	Иначе
		РезультатВыполнения = ДлительныеОперации.ЗапуститьВыполнениеВФоне(
		УникальныйИдентификатор,
		"УчетНДСПереопределяемый.ПодготовитьПараметрыКнигиПокупок",
		ПараметрыОтчета,
		БухгалтерскиеОтчетыКлиентСервер.ПолучитьНаименованиеЗаданияВыполненияОтчета(ЭтаФорма));
		
		ИдентификаторЗадания = РезультатВыполнения.ИдентификаторЗадания;
		АдресХранилища       = РезультатВыполнения.АдресХранилища;
	КонецЕсли;
	
	Если РезультатВыполнения.ЗаданиеВыполнено Тогда
		ЗагрузитьПодготовленныеДанные();
	КонецЕсли;
	
	Элементы.Сформировать.КнопкаПоУмолчанию = Истина;
	
	Возврат РезультатВыполнения;
	
КонецФункции

&НаСервере
Процедура ЗагрузитьПодготовленныеДанные()

	РезультатВыполнения = ПолучитьИзВременногоХранилища(АдресХранилища);
	
	Если РезультатВыполнения.Свойство("СписокСформированныхЛистов") Тогда
		
		Отчет.СписокСформированныхЛистов = РезультатВыполнения.СписокСформированныхЛистов;
		Элементы.СписокВыбораЛиста.СписокВыбора.Очистить();
		Если Отчет.СписокСформированныхЛистов.Количество() <> 0 Тогда
			Для Каждого Лист Из Отчет.СписокСформированныхЛистов Цикл
				Элементы.СписокВыбораЛиста.СписокВыбора.Добавить(Лист.Представление);
			КонецЦикла;
			СписокВыбораЛиста = Отчет.СписокСформированныхЛистов.Получить(0).Представление;
			Если Отчет.СписокСформированныхЛистов.Количество() <= 1 Тогда
				Элементы.СписокВыбораЛиста.Видимость = Ложь;
			Иначе
				Элементы.СписокВыбораЛиста.Видимость = Истина;
			КонецЕсли;
			
			ОпределитьИндексОсновногоРаздела();
			
		КонецЕсли;
		
		РезультатВыполнения.Свойство("ОткрыватьПомощникИзМакета", ОткрыватьПомощникИзМакета);
		
		ПоказатьВыбранныйЛист();
		ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(Элементы.Результат, "НеИспользовать");
		
	КонецЕсли;
	
	Если РезультатВыполнения.Свойство("СписокСообщений") Тогда
		Для Каждого Сообщение Из РезультатВыполнения.СписокСообщений Цикл
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение.Значение);
		КонецЦикла;
	КонецЕсли;
	
	// Проверка контрагентов
	Если ИспользованиеПроверкиВозможно И РезультатВыполнения.Свойство("ДанныеДляПроверкиКонтрагентов") Тогда
		
		ДанныеДляПроверкиКонтрагентов = РезультатВыполнения.ДанныеДляПроверкиКонтрагентов;
		
		Если ДанныеДляПроверкиКонтрагентов.Свойство("АдресДанныхКниги") Тогда
			АдресДанныхКниги = ДанныеДляПроверкиКонтрагентов.АдресДанныхКниги;
		КонецЕсли;
		
		ЗначениеВРеквизитФормы(ДанныеДляПроверкиКонтрагентов.НедействующиеКонтрагенты, "НедействующиеКонтрагенты");
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьИндексСформированногоЛиста(ИмяЛиста, СписокСформированныхЛистов)

	Если ИмяЛиста = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	Для Каждого Лист Из СписокСформированныхЛистов Цикл
		Если Лист.Представление = ИмяЛиста Тогда
			Возврат СписокСформированныхЛистов.Индекс(Лист);
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции

&НаСервере
Процедура ПоказатьВыбранныйЛист()

	Результат.Очистить();

	ИндексСформированногоЛиста = ПолучитьИндексСформированногоЛиста(СписокВыбораЛиста, Отчет.СписокСформированныхЛистов);

	Если ИндексСформированногоЛиста <> Неопределено Тогда

		Если ИспользованиеПроверкиВозможно И ЕстьОсновнойРаздел 
			И ИндексСформированногоЛиста = ИндексОсновногоРаздела // это основной раздел
			И НЕ ВыведеныВсеСтроки Тогда // пользователь выбрал режим просмотра - "Только контрагенты с ошибками"
			
			// Выводим только контрагентов с ошибками
			Результат.Вывести(КонтрагентыСОшибками);
		Иначе
			СформированныйЛист = Отчет.СписокСформированныхЛистов.Получить(ИндексСформированногоЛиста).Значение;
			Результат.Вывести(СформированныйЛист);
		КонецЕсли;

		Результат.ЧерноБелаяПечать = Истина;
		
		РассчитатьОбластьПечати();
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПроверитьВыполнениеЗадания()

	Попытка
		Если ЗаданиеВыполнено(ИдентификаторЗадания) Тогда
			ЗагрузитьПодготовленныеДанные();
			ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(Элементы.Результат, "НеИспользовать");
			ЗапуститьПроверкуКонтрагентов();
		Иначе
			ДлительныеОперацииКлиент.ОбновитьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
			ПодключитьОбработчикОжидания(
				"Подключаемый_ПроверитьВыполнениеЗадания",
				ПараметрыОбработчикаОжидания.ТекущийИнтервал,
				Истина);
		КонецЕсли;
	Исключение
		ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(Элементы.Результат, "НеИспользовать");
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

&НаСервере
Процедура ОтменитьВыполнениеЗадания()
	
	ДлительныеОперации.ОтменитьВыполнениеЗадания(ИдентификаторЗадания);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЗаданиеВыполнено(ИдентификаторЗадания)
	
	Возврат ДлительныеОперации.ЗаданиеВыполнено(ИдентификаторЗадания);
	
КонецФункции

&НаСервере
Процедура ВычислитьСуммуВыделенныхЯчеекТабличногоДокументаВКонтекстеНаСервере()
	
	ПолеСумма = БухгалтерскиеОтчетыВызовСервера.ВычислитьСуммуВыделенныхЯчеекТабличногоДокумента(
		Результат, КэшВыделеннойОбласти);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_РезультатПриАктивизацииОбластиПодключаемый()
	
	НеобходимоВычислятьНаСервере = Ложь;
	БухгалтерскиеОтчетыКлиент.ВычислитьСуммуВыделенныхЯчеекТабличногоДокумента(
		ПолеСумма, Результат, КэшВыделеннойОбласти, НеобходимоВычислятьНаСервере);
	
	Если НеобходимоВычислятьНаСервере Тогда
		ВычислитьСуммуВыделенныхЯчеекТабличногоДокументаВКонтекстеНаСервере();
	КонецЕсли;
	
	ОтключитьОбработчикОжидания("Подключаемый_РезультатПриАктивизацииОбластиПодключаемый");
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьРеквизитыИзПараметровФормы(Форма)
	
	ПараметрыЗаполненияФормы = Неопределено;
	
	Если Форма.Параметры.Свойство("ПараметрыЗаполненияФормы",ПараметрыЗаполненияФормы) Тогда
	
		ЗаполнитьЗначенияСвойств(Форма.Отчет,ПараметрыЗаполненияФормы);			
		
	КонецЕсли; 		

КонецПроцедуры

&НаКлиенте
Процедура ВыборСчетФактурыЗавершение(ЭлементВыбора, ДополнительныеПараметры) Экспорт
	
	Если ЭлементВыбора <> Неопределено Тогда
		ПоказатьЗначение( , ЭлементВыбора.Значение);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьПериодЗавершение(РезультатВыбора, ДопПараметры) Экспорт
	
	Если РезультатВыбора = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ЗаполнитьЗначенияСвойств(Отчет, РезультатВыбора, "НачалоПериода,КонецПериода");
	
	ОбновитьТекстЗаголовка(ЭтаФорма); 
	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОткрытьНастройки()
    Элементы.РазделыОтчета.ТекущаяСтраница = Элементы.НастройкиОтчета;
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ЗакрытьНастройки()
	Элементы.РазделыОтчета.ТекущаяСтраница = Элементы.Отчет;	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ПОЛЯ ТАБЛИЧНОГО ДОКУМЕНТА

&НаКлиенте
Процедура РезультатПриАктивизацииОбласти(Элемент)
	
	Если ТипЗнч(Результат.ВыделенныеОбласти) = Тип("ВыделенныеОбластиТабличногоДокумента") Тогда
		ИнтервалОжидания = ?(ПолучитьСкоростьКлиентскогоСоединения() = СкоростьКлиентскогоСоединения.Низкая, 1, 0.2);
		ПодключитьОбработчикОжидания("Подключаемый_РезультатПриАктивизацииОбластиПодключаемый", ИнтервалОжидания, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	Если ТипЗнч(Расшифровка) = Тип("СписокЗначений") Тогда
		СтандартнаяОбработка = Ложь;
		Оповещение = Новый ОписаниеОповещения("ВыборСчетФактурыЗавершение", ЭтотОбъект);
		Расшифровка.ПоказатьВыборЭлемента(Оповещение, НСтр("ru = 'Выберите счет-фактуру'"));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатВыбор(Элемент, Область, СтандартнаяОбработка)
	
	Если Результат.Области.Найти("ПерейтиКПомощнику") <> Неопределено Тогда
		Если Область.Верх = Результат.Области.ПерейтиКПомощнику.Верх Тогда
			СтандартнаяОбработка = Ложь;
			УчетНДСКлиентПереопределяемый.ОткрытьФормуПомощникаПоУчетуНДС(Область.Расшифровка);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ДЕЙСТВИЯ КОМАНД ФОРМЫ

&НаКлиенте
Процедура СформироватьОтчет(Команда)
	
	ОчиститьСообщения();
	
	ОтключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания");

	РезультатВыполнения = СформироватьОтчетНаСервере();
	Если Не РезультатВыполнения.ЗаданиеВыполнено Тогда
		ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		ПодключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания", 1, Истина);
		ОбщегоНазначенияКлиентСервер.УстановитьСостояниеПоляТабличногоДокумента(Элементы.Результат, "ФормированиеОтчета");
	Иначе
		ЗапуститьПроверкуКонтрагентов();
	КонецЕсли;
	
	Если РезультатВыполнения.Свойство("ОтказПроверкиЗаполнения") Тогда
		ПоказатьНастройки("");
	Иначе	
		ПодключитьОбработчикОжидания("Подключаемый_ЗакрытьНастройки", 0.1, Истина);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПоказатьНастройки(Команда)
	Элементы.ПрименитьНастройки.КнопкаПоУмолчанию = Истина;
	ПодключитьОбработчикОжидания("Подключаемый_ОткрытьНастройки", 0.1, Истина);	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьНастройки(Команда)
	Элементы.Сформировать.КнопкаПоУмолчанию = Истина;
	ПодключитьОбработчикОжидания("Подключаемый_ЗакрытьНастройки", 0.1, Истина);	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьПериод(Команда)	
		
	//Изменила Федотова Л., РГ-Софт, 22.05.15, вопрос PA_-0000349
	
	//ПараметрыВыбора = Новый Структура("НачалоПериода,КонецПериода", Отчет.НачалоПериода, Отчет.КонецПериода);
	//ОписаниеОповещения = Новый ОписаниеОповещения("ВыбратьПериодЗавершение", ЭтотОбъект);
	//ОткрытьФорму("ОбщаяФорма.ВыборСтандартногоПериода", ПараметрыВыбора, Элементы.ВыбратьПериод, , , , ОписаниеОповещения);
	
	П = Новый СтандартныйПериод;
	П.ДатаНачала 		= ?(ЗначениеЗаполнено(Отчет.НачалоПериода), Отчет.НачалоПериода, НачалоКвартала(ТекущаяДата()));
	П.ДатаОкончания 	= ?(ЗначениеЗаполнено(Отчет.КонецПериода), Отчет.КонецПериода, КонецКвартала(ТекущаяДата()));
	П.Вариант 			= ВариантСтандартногоПериода.ЭтотКвартал;
	
	ДиалогВыбора = Новый ДиалогРедактированияСтандартногоПериода;
	ДиалогВыбора.Период = П; 
	
	Если ДиалогВыбора.Редактировать() Тогда
		
		П = ДиалогВыбора.Период;
		
		Отчет.НачалоПериода 	= П.ДатаНачала;
		Отчет.КонецПериода 	= П.ДатаОкончания;
		
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ФОРМЫ

&НаКлиенте
Процедура НачалоПериодаПриИзменении(Элемент)
	
	ОбновитьТекстЗаголовка(ЭтаФорма);
	
	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КонецПериодаПриИзменении(Элемент)
	
	ОбновитьТекстЗаголовка(ЭтаФорма);
	
	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолеОрганизацияПриИзменении(Элемент)
	
	ОбщегоНазначенияБПКлиент.ПолеОрганизацияПриИзменении(Элемент, ПолеОрганизация,
		Отчет.Организация, Отчет.ВключатьОбособленныеПодразделения);
	
	ОбновитьТекстЗаголовка(ЭтаФорма);
	
	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура ПолеОрганизацияОткрытие(Элемент, СтандартнаяОбработка)
	
	ОбщегоНазначенияБПКлиент.ПолеОрганизацияОткрытие(Элемент, СтандартнаяОбработка,
		ПолеОрганизация, СоответствиеОрганизаций);
		
КонецПроцедуры
	
&НаКлиенте
Процедура ПолеОрганизацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	ОбщегоНазначенияБПКлиент.ПолеОрганизацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка, 
		СоответствиеОрганизаций, Отчет.Организация, Отчет.ВключатьОбособленныеПодразделения);
	
КонецПроцедуры
	
&НаКлиенте
Процедура ФормироватьДополнительныеЛистыПриИзменении(Элемент)

	Если НЕ Отчет.ФормироватьДополнительныеЛисты И Отчет.ВыводитьТолькоДопЛисты Тогда
		Отчет.ВыводитьТолькоДопЛисты = Ложь;
	КонецЕсли;

	УправлениеФормой(ЭтаФорма);

	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СписокВыбораЛистаПриИзменении(Элемент)

	ПоказатьВыбранныйЛист();
	ВывестиНужнуюПанельПроверкиКонтрагентов();
	
КонецПроцедуры

&НаКлиенте
Процедура ДополнительныеЛистыЗаТекущийПериодПриИзменении(Элемент)

	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ВыводитьТолькоДопЛистыПриИзменении(Элемент)

	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ВыводитьПокупателейПоАвансамПриИзменении(Элемент)

	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура КонтрагентДляОтбораПриИзменении(Элемент)

	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ГруппироватьПоКонтрагентамПриИзменении(Элемент)

	Если Не ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ПроверкаКонтрагентовКлиент.СброситьАктуальностьОтчета(ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьЗначенияСвойств(Отчет, Параметры);
	
	// Установка настроек печати по умолчанию.
	// Если настройки были изменены, они будут загружены при формировании отчета.
	Результат.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	Результат.АвтоМасштаб        = Истина;
	
	Если НЕ ЗначениеЗаполнено(Отчет.НачалоПериода) Тогда
		Отчет.НачалоПериода = НачалоКвартала(ОбщегоНазначенияБП.ПолучитьРабочуюДату());
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Отчет.КонецПериода) Тогда
		Отчет.КонецПериода  = КонецКвартала(ОбщегоНазначенияБП.ПолучитьРабочуюДату());
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Отчет.Организация) Тогда
		Отчет.Организация   = БухгалтерскийУчетПереопределяемый.ПолучитьЗначениеПоУмолчанию("ОсновнаяОрганизация");
	КонецЕсли;
	
	ЗаполнитьРеквизитыИзПараметровФормы(ЭтаФорма);
	
	УправлениеФормой(ЭтаФорма);
	
	ОбщегоНазначенияБПВызовСервера.ЗаполнитьСписокОрганизаций(Элементы.ПолеОрганизация, СоответствиеОрганизаций);
	
	#Область ПроверкаКонтрагентов
	
	ИспользованиеПроверкиВозможно = ПроверкаКонтрагентовВызовСервера.ИспользованиеПроверкиВозможно();
	ПроверкаКонтрагентов.УстановитьНадписиВПанелиОтчетаПриСозданииНаСервере(ЭтаФорма);
	ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект);
	
	#КонецОбласти
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеПользовательскихНастроекНаСервере(Настройки)

	БухгалтерскиеОтчетыВызовСервера.ПриЗагрузкеПользовательскихНастроекНаСервере(ЭтаФорма, Настройки, Истина);

	ОбновитьТекстЗаголовка(ЭтаФорма);

	ЗаполнитьРеквизитыИзПараметровФормы(ЭтаФорма);
	
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура ПриСохраненииПользовательскихНастроекНаСервере(Настройки)

	БухгалтерскиеОтчетыВызовСервера.ПриСохраненииПользовательскихНастроекНаСервере(ЭтаФорма, Настройки, Истина);

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбновитьТекстЗаголовка(ЭтаФорма);
	
	БухгалтерскиеОтчетыКлиент.ПриОткрытии(ЭтаФорма, Отказ);
	
	Если НЕ ИспользованиеПроверкиВозможно Тогда
		ПодключитьОбработчикОжидания("Подключаемый_ПоказатьПредложениеИспользоватьПроверкуКонтрагентов", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)

	БухгалтерскиеОтчетыКлиент.ПередЗакрытием(ЭтаФорма, Отказ, СтандартнаяОбработка);

КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()

	Если ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		ОтменитьВыполнениеЗадания();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	Если ПолеОрганизация <> "" Тогда
		Если НЕ СоответствиеОрганизаций.Свойство(ПолеОрганизация) Тогда
			ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
				"Поле", "Заполнение", НСтр("ru = 'Организация'"), , ,);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "ПолеОрганизация", , Отказ);
		КонецЕсли; 
	КонецЕсли; 

КонецПроцедуры

&НаСервере
Функция ПодготовитьПараметрыОтчета(ЭтоФормированиеОтчетаДоПроверкиКонтрагентов) Экспорт

	ПараметрыОтчета = Новый Структура;
	ПараметрыОтчета.Вставить("Организация"                       , Отчет.Организация);
	ПараметрыОтчета.Вставить("НачалоПериода"                     , Отчет.НачалоПериода);
	ПараметрыОтчета.Вставить("КонецПериода"                      , Отчет.КонецПериода);
	ПараметрыОтчета.Вставить("ФормироватьДополнительныеЛисты"    , Отчет.ФормироватьДополнительныеЛисты);
	ПараметрыОтчета.Вставить("ДополнительныеЛистыЗаТекущийПериод", Отчет.ДополнительныеЛистыЗаТекущийПериод);
	ПараметрыОтчета.Вставить("ГруппироватьПоКонтрагентам"        , Отчет.ГруппироватьПоКонтрагентам);
	ПараметрыОтчета.Вставить("КонтрагентДляОтбора"               , Отчет.КонтрагентДляОтбора);
	ПараметрыОтчета.Вставить("ВыводитьТолькоДопЛисты"            , Отчет.ВыводитьТолькоДопЛисты);
	ПараметрыОтчета.Вставить("ВыводитьПокупателейПоАвансам"      , Отчет.ВыводитьПокупателейПоАвансам);
	ПараметрыОтчета.Вставить("ВключатьОбособленныеПодразделения" , Отчет.ВключатьОбособленныеПодразделения);
	ПараметрыОтчета.Вставить("СписокСформированныхЛистов"        , Отчет.СписокСформированныхЛистов);
	ПараметрыОтчета.Вставить("СформироватьОтчетПоСтандартнойФорме");
	ПараметрыОтчета.Вставить("ОтбиратьПоКонтрагенту", 				ЗначениеЗаполнено(Отчет.КонтрагентДляОтбора));
	ПараметрыОтчета.Вставить("СписокОрганизаций");
	ПараметрыОтчета.Вставить("ДатаФормированияДопЛиста"); 
	ПараметрыОтчета.Вставить("ЗаполнениеДокумента",  Ложь);
	ПараметрыОтчета.Вставить("ЗаполнениеДекларации", Ложь);
	
	ДобавитьПараметрыДляПроверкиКонтрагентов(ПараметрыОтчета, ЭтоФормированиеОтчетаДоПроверкиКонтрагентов);
	
	Возврат ПараметрыОтчета;

КонецФункции

#Область ПроверкаКонтрагентов

&НаСервере
Процедура ДобавитьПараметрыДляПроверкиКонтрагентов(ПараметрыОтчета, ЭтоФормированиеОтчетаДоПроверкиКонтрагентов) Экспорт
	
	ДанныеДляПроверкиКонтрагентов = Новый Структура;
	ДанныеДляПроверкиКонтрагентов.Вставить("ЭтоКнигаПокупок", 				Истина);
	ДанныеДляПроверкиКонтрагентов.Вставить("ИспользованиеПроверкиВозможно", ИспользованиеПроверкиВозможно);
	
	Если ЭтоФормированиеОтчетаДоПроверкиКонтрагентов Тогда
		ДанныеДляПроверкиКонтрагентов.Вставить("АдресДанныхКниги", 	ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор));
	Иначе
		
		ДанныеДляПроверкиКонтрагентов.Вставить("ЗаписиКниги", 				ПолучитьИзВременногоХранилища(АдресДанныхКниги));
		ДанныеДляПроверкиКонтрагентов.Вставить("ИндексОсновногоРаздела", 	ИндексОсновногоРаздела);
		ДанныеДляПроверкиКонтрагентов.Вставить("СписокСформированныхЛистов",Отчет.СписокСформированныхЛистов);
		ПараметрыОтчета.Вставить("ФормироватьДополнительныеЛисты" , Ложь);
		
	КонецЕсли;
	ДанныеДляПроверкиКонтрагентов.Вставить("НедействующиеКонтрагенты", 	РеквизитФормыВЗначение("НедействующиеКонтрагенты", Тип("ТаблицаЗначений")));
	ДанныеДляПроверкиКонтрагентов.Вставить("ВыводитьТолькоНекорректныхКонтрагентов", НЕ ЭтоФормированиеОтчетаДоПроверкиКонтрагентов);
	ПараметрыОтчета.Вставить("ДанныеДляПроверкиКонтрагентов", ДанныеДляПроверкиКонтрагентов);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПоказатьПредложениеИспользоватьПроверкуКонтрагентов()
	
	ПроверкаКонтрагентовКлиент.ПредложитьВключитьПроверкуКонтрагентов(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьПроверкуКонтрагентов()
	
	ПроверкаКонтрагентовВыполнялась = Ложь;
	Если ЕстьОсновнойРаздел И ИспользованиеПроверкиВозможно И НедействующиеКонтрагенты.Количество() > 0 Тогда
		
		Если ЕстьДоступКВебСервисуФНС Тогда
			ОтключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов");
			ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект, "ПроверкаВПроцессеВыполнения");

			РезультатПроверки = ПроверитьКонтрагентов();
			
			Если РезультатПроверки <> Неопределено Тогда
				// Результат получен и уже обработан на стороне сервера
				ОтобразитьРезультатПроверкиКонтрагента();
				ИдентификаторЗадания = Неопределено;
			ИначеЕсли ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
				// Результата еще нет, но есть шансы дождаться
				ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
				ПодключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов", 1, Истина);
			КонецЕсли;
		Иначе
			ВывестиНужнуюПанельПроверкиКонтрагентов();
		КонецЕсли;
	Иначе
		ВывестиНужнуюПанельПроверкиКонтрагентов();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПроверитьКонтрагентов()
	
	ИдентификаторЗадания = Неопределено;
	
	ПараметрыОтчета = ПодготовитьПараметрыОтчета(Ложь);
	
	НаименованиеЗадания = НСтр("ru = 'Проверка контрагентов в книге покупок'");
	РезультатПроверки = ДлительныеОперации.ЗапуститьВыполнениеВФоне(
		УникальныйИдентификатор,
		"УчетНДС.ОпределитьНедействующихКонтрагентовВКнигахФоновоеЗадание",
		ПараметрыОтчета,
		НаименованиеЗадания);

	АдресХранилища       = РезультатПроверки.АдресХранилища;
	ИдентификаторЗадания = РезультатПроверки.ИдентификаторЗадания;
	
	Если Не РезультатПроверки.ЗаданиеВыполнено Тогда
		// Надо ждать
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура Подключаемый_ОбработатьРезультатПроверкиКонтрагентов()

	Попытка
		Если ЗаданиеВыполнено(ИдентификаторЗадания) Тогда
			ОтобразитьРезультатПроверкиКонтрагента();
			ИдентификаторЗадания = Неопределено;
		Иначе
			ДлительныеОперацииКлиент.ОбновитьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
			ПодключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов",
				ПараметрыОбработчикаОжидания.ТекущийИнтервал, Истина);
		КонецЕсли;
	Исключение
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

&НаСервере
Процедура ОтобразитьРезультатПроверкиКонтрагента()

	РезультатПроверки = ПолучитьИзВременногоХранилища(АдресХранилища);
	
	Если РезультатПроверки.Свойство("НетДоступаКВебСервисуФНС") Тогда
		// Не удалось проверить контрагентов
		ЕстьДоступКВебСервисуФНС = Ложь;
	Иначе
		ЗначениеВРеквизитФормы(РезультатПроверки.НедействующиеКонтрагенты, "НедействующиеКонтрагенты");
		КонтрагентыСОшибками = РезультатПроверки.КонтрагентыСОшибками;
		Отчет.СписокСформированныхЛистов.Получить(ИндексОсновногоРаздела).Значение = РезультатПроверки.ОсновнойРаздел;
	КонецЕсли;
	
	ПоказатьВыбранныйЛист();
	
	ПроверкаКонтрагентовВыполнялась = Истина;
		
	ВывестиНужнуюПанельПроверкиКонтрагентов();

КонецПроцедуры

&НаСервере
Процедура ВывестиНужнуюПанельПроверкиКонтрагентов()

	Если ИспользованиеПроверкиВозможно Тогда
		
		Если ЕстьДоступКВебСервисуФНС Тогда
		
			ИндексСформированногоЛиста = ПолучитьИндексСформированногоЛиста(СписокВыбораЛиста, Отчет.СписокСформированныхЛистов);
			
			Если ИндексСформированногоЛиста <> Неопределено И ЕстьОсновнойРаздел И ИндексСформированногоЛиста = ИндексОсновногоРаздела И ПроверкаКонтрагентовВыполнялась Тогда
				// Книга открыта на основном разделе
				
				КонтрагентыСПустымСостоянием = НедействующиеКонтрагенты.НайтиСтроки(Новый Структура("Состояние", Перечисления.СостоянияСуществованияКонтрагента.ПустаяСсылка()));
				Если НедействующиеКонтрагенты.Количество() = 0 Тогда 
					ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект, "ВсеКонтрагентыКорректные");
				ИначеЕсли НедействующиеКонтрагенты.Количество() > 0 И КонтрагентыСПустымСостоянием.Количество() = НедействующиеКонтрагенты.Количество() Тогда
					// Ни один контрагенты не проверен
					ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект, "НетДоступаКСервису");
				ИначеЕсли НедействующиеКонтрагенты.Количество() > 0 Тогда
					// Контрагенты проверены
					ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект, "НайденыНекорректныеКонтрагенты");
				КонецЕсли;
			Иначе
				// Книга открыта на доп листе
				ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект);
			КонецЕсли;
			
		Иначе
			 ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект, "НетДоступаКСервису");
		КонецЕсли;
		
	Иначе
		ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура РассчитатьОбластьПечати()

	ПерваяСтрока = 1;
	
	Если ОткрыватьПомощникИзМакета Тогда
		ПерваяСтрока = ПерваяСтрока + 1;
	КонецЕсли;
	
	Результат.ОбластьПечати = Результат.Область(ПерваяСтрока,1,Результат.ВысотаТаблицы, Результат.ШиринаТаблицы);

КонецПроцедуры

&НаСервере
Процедура ОпределитьИндексОсновногоРаздела()

	Индекс = ПолучитьИндексСформированногоЛиста("Основной раздел", отчет.СписокСформированныхЛистов);
	
	Если Индекс = Неопределено Тогда
		ИндексОсновногоРаздела 	= 0;
		ЕстьОсновнойРаздел 		= Ложь;
	Иначе
		ИндексОсновногоРаздела 	= Индекс;
		ЕстьОсновнойРаздел 		= Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПереключательРежимаОтображенияПриИзменении(Элемент)
	
	ВыведеныВсеСтроки = НЕ ВыведеныВсеСтроки;
	ПроверкаКонтрагентовКлиентСервер.СменитьВидПанелиПроверкиКонтрагента(ЭтотОбъект, "НайденыНекорректныеКонтрагенты");
	ПоказатьВыбранныйЛист();

КонецПроцедуры

#КонецОбласти


