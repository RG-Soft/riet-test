#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ПрограммныйИнтерфейс

Функция СформироватьИдентификаторРеестра(РеестрОбъект = Неопределено) Экспорт
	
	Номер = Формат(ТекущаяДата(), "ДФ=dd.MM.yyyy") + " - " + СокрЛП(РеестрОбъект.Подрядчик);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Реестры.Ссылка) КАК КоличествоРеестров
	|ИЗ
	|	Справочник.Реестры КАК Реестры
	|ГДЕ
	|	Реестры.Наименование ПОДОБНО &Наименование
	|	И НЕ Реестры.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("Наименование", Номер+"%");
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Результат.Следующий();
	
	Номер = Номер + "-" + (Результат.КоличествоРеестров + 1);
	
	Возврат Номер;
	
	//Префикс = "_SALAVAT-";
	//Возврат Формат(ТекущаяДата(), "ДФ=ddMMyyyy")+ Префикс + ПолучитьНомерРеестра();
	
КонецФункции

Процедура ЗаписатьЛоги(Отказ, ТекущийОбъект, ПараметрыЗаписи) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	СтрокаИсключаемыхРеквизитов = "Комментарий"; 
	ТекстИзменений = ImportExportСервер.РегистрацияИзмененийРеквизитовОбъекта(ТекущийОбъект, СтрокаИсключаемыхРеквизитов);
	
	Если ТекстИзменений = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	МенеджерЗаписи = РегистрыСведений.СтатусыРеестровLog.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.LogTo 	= ТекущийОбъект.Ссылка;
	МенеджерЗаписи.Date		= ТекущаяДата();	
	МенеджерЗаписи.LogType	= Справочники.LogTypes.ИзменениеРеквизитов;
	МенеджерЗаписи.User		= ПараметрыСеанса.ТекущийПользователь;
	МенеджерЗаписи.Text		= ТекстИзменений;	
	МенеджерЗаписи.Записать();
	// } RGS AArsentev 09.09.2016 16:56:30 S-I-0001717
	
	УстановитьПривилегированныйРежим(Ложь);

КонецПроцедуры

Процедура ЗаписатьЛогиПринудительно(Объект, ТекстИзменений) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ТекстИзменений = Неопределено или ПустаяСтрока(ТекстИзменений) Тогда
		Возврат;
	КонецЕсли;
	
	МенеджерЗаписи = РегистрыСведений.СтатусыРеестровLog.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.LogTo 	= Объект.Ссылка;
	МенеджерЗаписи.Date		= ТекущаяДата();	
	МенеджерЗаписи.LogType	= Справочники.LogTypes.ИзменениеСтатуса;
	МенеджерЗаписи.User		= ПараметрыСеанса.ТекущийПользователь;
	МенеджерЗаписи.Text		= ТекстИзменений;	
	МенеджерЗаписи.Записать();
	// } RGS AArsentev 09.09.2016 16:56:30 S-I-0001717
	
	УстановитьПривилегированныйРежим(Ложь);

КонецПроцедуры

Функция СоздатьДокументRentalCosts(Ссылка) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Реестры.ПериодОказанияУслугНачало КАК ДатаНачала,
	|	Реестры.ПериодОказанияУслугОкончание КАК ДатаОкончания,
	|	Реестры.Регион КАК RegionProvince,
	|	Реестры.Поставки.(
	|		Поставка
	|	),
	|	Реестры.Подрядчик как ServiceProvider 
	|ИЗ
	|	Справочник.Реестры КАК Реестры
	|ГДЕ
	|	Реестры.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Док = Документы.RentalTrucksCostsSums.СоздатьДокумент();
	Док.Дата = ТекущаяДата();
	
	ЗаполнитьЗначенияСвойств(Док, Результат[0]);
	
	Трипы = Результат[0].Поставки;
	
	Для каждого ТекТрип из Трипы Цикл 
		
		Стр = Док.RentalTrucks.Добавить();
		Стр.Trip = ТекТрип.Поставка;
		
	КонецЦикла;	
	
	Док.ОбменДанными.Загрузка = Истина;
	Док.Comments = "Создан автоматически на основании реестра " + Строка(Ссылка);
	Док.Записать(РежимЗаписиДокумента.Запись);
	
	Возврат Док.Ссылка;
	
КонецФункции

Функция СоздатьДокументAPInvoice(Ссылка) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Реестры.ПериодОказанияУслугНачало КАК ДатаНачала,
	|	Реестры.ПериодОказанияУслугОкончание КАК ДатаОкончания,
	|	Реестры.Регион КАК RegionProvince,
	|	Реестры.Поставки.(
	|		Поставка
	|	),
	|	Реестры.Подрядчик КАК ServiceProvider
	|ИЗ
	|	Справочник.Реестры КАК Реестры
	|ГДЕ
	|	Реестры.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Док = Документы.APInvoice.СоздатьДокумент();
	Док.Дата = ТекущаяДата();
	
	ЗаполнитьЗначенияСвойств(Док, Результат[0]);
	
	Трипы = Результат[0].Поставки;
	
	Для каждого ТекТрип из Трипы Цикл 
		
		Стр = Док.Trips.Добавить();
		Стр.Trip = ТекТрип.Поставка;
		
	КонецЦикла;	
	
	Док.ОбменДанными.Загрузка = Истина;
	Док.Comments = "Создан автоматически на основании реестра " + Строка(Ссылка);
	Док.Записать(РежимЗаписиДокумента.Запись);
	
	Возврат Док.Ссылка;
	
КонецФункции
// работа с исходным реестром
Функция ИсходныйРеестрЗагружен(Реестр) Экспорт
	
	Если Реестр.Пустая() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст  = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	РеестрыПрисоединенныеФайлы.Ссылка
	|ИЗ
	|	Справочник.РеестрыПрисоединенныеФайлы КАК РеестрыПрисоединенныеФайлы
	|ГДЕ
	|	РеестрыПрисоединенныеФайлы.ВладелецФайла = &ВладелецФайла
	|	И РеестрыПрисоединенныеФайлы.Наименование = ""Original""
	|
	|УПОРЯДОЧИТЬ ПО
	|	РеестрыПрисоединенныеФайлы.ДатаСоздания УБЫВ";
	
	Запрос.УстановитьПараметр("ВладелецФайла", Реестр);
	
	Результат = Запрос.Выполнить();
	
	Возврат НЕ Результат.Пустой();
	
КонецФункции

Функция ПолучитьОригинальныйРеестр(Реестр) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст  = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	РеестрыПрисоединенныеФайлы.Ссылка
	|ИЗ
	|	Справочник.РеестрыПрисоединенныеФайлы КАК РеестрыПрисоединенныеФайлы
	|ГДЕ
	|	РеестрыПрисоединенныеФайлы.ВладелецФайла = &ВладелецФайла
	|	И РеестрыПрисоединенныеФайлы.Наименование = ""Original""
	|
	|УПОРЯДОЧИТЬ ПО
	|	РеестрыПрисоединенныеФайлы.ДатаСоздания УБЫВ";
	
	Запрос.УстановитьПараметр("ВладелецФайла", Реестр);
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Если Результат.Следующий() Тогда
		Возврат ПоместитьВоВременноеХранилище(ПрисоединенныеФайлы.ПолучитьДвоичныеДанныеФайла(Результат.Ссылка));
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

// работа с финальным реестром
Функция ФинальныйРеестрЗагружен(Реестр) Экспорт
	
	Если Реестр.Пустая() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст  = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	РеестрыПрисоединенныеФайлы.Ссылка
	|ИЗ
	|	Справочник.РеестрыПрисоединенныеФайлы КАК РеестрыПрисоединенныеФайлы
	|ГДЕ
	|	РеестрыПрисоединенныеФайлы.ВладелецФайла = &ВладелецФайла
	|	И РеестрыПрисоединенныеФайлы.Наименование = ""Final""
	|
	|УПОРЯДОЧИТЬ ПО
	|	РеестрыПрисоединенныеФайлы.ДатаСоздания УБЫВ";
	
	Запрос.УстановитьПараметр("ВладелецФайла", Реестр);
	
	Результат = Запрос.Выполнить();
	
	Возврат НЕ Результат.Пустой();
	
КонецФункции

Функция ПолучитьФинальныйРеестр(Реестр) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст  = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	РеестрыПрисоединенныеФайлы.Ссылка
	|ИЗ
	|	Справочник.РеестрыПрисоединенныеФайлы КАК РеестрыПрисоединенныеФайлы
	|ГДЕ
	|	РеестрыПрисоединенныеФайлы.ВладелецФайла = &ВладелецФайла
	|	И РеестрыПрисоединенныеФайлы.Наименование = ""Final""
	|
	|УПОРЯДОЧИТЬ ПО
	|	РеестрыПрисоединенныеФайлы.ДатаСоздания УБЫВ";
	
	Запрос.УстановитьПараметр("ВладелецФайла", Реестр);
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Если Результат.Следующий() Тогда
		Возврат ПоместитьВоВременноеХранилище(ПрисоединенныеФайлы.ПолучитьДвоичныеДанныеФайла(Результат.Ссылка));
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

Процедура УведомитьПоЭлектроннойПочте(Адреса, Тема, Сообщение) Экспорт
		
	Если НЕ ЗначениеЗаполнено(Адреса) Тогда
		Возврат;
	КонецЕсли;
	
	РГСофт.ЗарегистрироватьПочтовоеСообщение(Адреса, Тема, Сообщение);
	
КонецПроцедуры

Функция ПолучитьРеестрДляТрипа(СсылкаНаТрип) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	РеестрыПоставки.Ссылка
	|ИЗ
	|	Справочник.Реестры.Поставки КАК РеестрыПоставки
	|ГДЕ
	|	РеестрыПоставки.Поставка = &Поставка";
	
	Запрос.УстановитьПараметр("Поставка", СсылкаНаТрип);
	
	Рез = Запрос.Выполнить().Выбрать();
	
	Если Рез.Следующий() Тогда
		Возврат Рез.Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

#КонецОбласти

Функция ПолучитьНомерРеестра()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Реестры.Код КАК Код
	|ИЗ
	|	Справочник.Реестры КАК Реестры
	|
	|УПОРЯДОЧИТЬ ПО
	|	Код УБЫВ";
	
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Если Результат.Следующий() Тогда
		
		Номер = Результат.Код;
		// удаление ведущих нулей
		Пока Лев(Номер, 1)="0" Цикл
			Номер = Сред(Номер, 2);
		КонецЦикла;
		Номер = Формат(Число(Номер) + 1, "ЧГ=0");
		Возврат Номер;
		
	Иначе
		Возврат 1;
	КонецЕсли;
	
КонецФункции

#КонецЕсли