// Функция выполняет пропорциональное распределение суммы в соответствии
// с заданными коэффициентами распределения
//
// Параметры:
//		ИсхСумма - распределяемая сумма
//		МассивКоэф - массив коэффициентов распределения
//		Точность - точность округления при распределении. Необязателен.
//
//	Возврат:
//		МассивСумм - массив размерностью равный массиву коэффициентов, содержит
//			суммы в соответствии с весом коэффициента (из массива коэффициентов)
//          В случае если распределить не удалось (сумма = 0, кол-во коэф. = 0,
//          или суммарный вес коэф. = 0), тогда возвращается значение Неопределено
//
Функция РаспределитьПропорционально(Знач ИсхСумма, МассивКоэф, Знач Точность = 2) Экспорт

	Если МассивКоэф.Количество() = 0 Или ИсхСумма = 0 Или ИсхСумма = Null Тогда
		Возврат Неопределено;
	КонецЕсли;

	ИндексМакс = 0;
	МаксЗнач   = 0;
	РаспрСумма = 0;
	СуммаКоэф  = 0;

	Для К = 0 По МассивКоэф.Количество() - 1 Цикл

		МодульЧисла = ?(МассивКоэф[К] > 0, МассивКоэф[К], - МассивКоэф[К]);

		Если МаксЗнач < МодульЧисла Тогда
			МаксЗнач   = МодульЧисла;
			ИндексМакс = К;
		КонецЕсли;

		СуммаКоэф = СуммаКоэф + МассивКоэф[К];

	КонецЦикла;

	Если СуммаКоэф = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;

	МассивСумм = Новый Массив(МассивКоэф.Количество());

	Для К = 0 По МассивКоэф.Количество() - 1 Цикл
		МассивСумм[К] = Окр(ИсхСумма * МассивКоэф[К] / СуммаКоэф, Точность, 1);
		РаспрСумма    = РаспрСумма + МассивСумм[К];
	КонецЦикла;

	// Погрешности округления отнесем на коэффицент с максимальным весом
	Если Не РаспрСумма = ИсхСумма Тогда
		МассивСумм[ИндексМакс] = МассивСумм[ИндексМакс] + ИсхСумма - РаспрСумма;
	КонецЕсли;

	Возврат МассивСумм;

КонецФункции // РаспределитьПропорционально()

Процедура ЗаполнитьСчетНалоговогоУчетаВСтрокеТабличногоПоля(СтрокаТабличнойЧасти, ИзменениеСубконто = ЛОЖЬ, ИмяСчетаЗатрат = "СчетЗатрат", ИмяСчетаЗатратНУ = "СчетЗатратНУ", ЕстьСубконто = Ложь, Знач ТекущаяДата = Неопределено) Экспорт

	ВидЗатратНУ = Перечисления.ВидыРасходовНУ.ПустаяСсылка();

	Если ЕстьСубконто Тогда

		Если ТипЗнч(СтрокаТабличнойЧасти.Субконто1) = Тип("СправочникСсылка.СтатьиЗатрат") Тогда
			ВидЗатратНУ = СтрокаТабличнойЧасти.Субконто1.ВидРасходовНУ;

		ИначеЕсли ТипЗнч(СтрокаТабличнойЧасти.Субконто2) = Тип("СправочникСсылка.СтатьиЗатрат") Тогда
			ВидЗатратНУ = СтрокаТабличнойЧасти.Субконто2.ВидРасходовНУ;

		ИначеЕсли ТипЗнч(СтрокаТабличнойЧасти.Субконто3) = Тип("СправочникСсылка.СтатьиЗатрат") Тогда
			ВидЗатратНУ = СтрокаТабличнойЧасти.Субконто3.ВидРасходовНУ;

		ИначеЕсли ИзменениеСубконто Тогда
			Возврат;

		КонецЕсли;

	КонецЕсли;

	Если НЕ ОбщегоНазначения.ЗначениеНеЗаполнено(ВидЗатратНУ) Тогда
		СтрокаТабличнойЧасти[ИмяСчетаЗатратНУ] = БухгалтерскийУчет.ПреобразоватьСчетаБУвСчетНУ(Новый Структура("СчетБУ, ВидЗатратНУ", СтрокаТабличнойЧасти[ИмяСчетаЗатрат], ВидЗатратНУ), , , ТекущаяДата);

	Иначе
		СтрокаТабличнойЧасти[ИмяСчетаЗатратНУ] = БухгалтерскийУчет.ПреобразоватьСчетаБУвСчетНУ(Новый Структура("СчетБУ, ", СтрокаТабличнойЧасти[ИмяСчетаЗатрат]), , , ТекущаяДата);

	КонецЕсли;

КонецПроцедуры // ЗаполнитьСчетНалоговогоУчетаВСтрокеТабличногоПоля()

// Процедура устанавливает видимость ячеек для ввода аналитики в зависимости от указанной статьи затрат.
//
Процедура НастроитьВидимостьЯчеекАналитикиЗатрат(СчетЗатрат = НЕОПРЕДЕЛЕНО, СчетЗатратНУ = НЕОПРЕДЕЛЕНО, ОформлениеСтроки, ОтражатьВБухгалтерскомУчете, ОтражатьВНалоговомУчете) Экспорт

	Если НЕ ОформлениеСтроки.Ячейки.Найти("Аналитика") = НЕОПРЕДЕЛЕНО Тогда
		ОформлениеСтроки.Ячейки.Аналитика.Видимость    = Ложь;
	КонецЕсли;

	Если НЕ ОформлениеСтроки.Ячейки.Найти("ВидАналитики") = НЕОПРЕДЕЛЕНО Тогда
		ОформлениеСтроки.Ячейки.ВидАналитики.Видимость = Ложь;
	КонецЕсли;

	Если НЕ ОформлениеСтроки.Ячейки.Найти("ВидСубконто3") = НЕОПРЕДЕЛЕНО Тогда

		Если НЕ ОбщегоНазначения.ЗначениеНеЗаполнено(СчетЗатрат) Тогда

			КоличествоСубконто = СчетЗатрат.ВидыСубконто.Количество();

			Если КоличествоСубконто > 0 Тогда
				ОформлениеСтроки.Ячейки.ВидСубконто1.УстановитьТекст(СчетЗатрат.ВидыСубконто.Получить(0).ВидСубконто);
			Иначе
				ОформлениеСтроки.Ячейки.ВидСубконто1.УстановитьТекст("");
			КонецЕсли;

			Если КоличествоСубконто > 1 Тогда
				ОформлениеСтроки.Ячейки.ВидСубконто2.УстановитьТекст(СчетЗатрат.ВидыСубконто.Получить(1).ВидСубконто);
			Иначе
				ОформлениеСтроки.Ячейки.ВидСубконто2.УстановитьТекст("");
			КонецЕсли;

			Если КоличествоСубконто > 2 Тогда
				ОформлениеСтроки.Ячейки.ВидСубконто3.УстановитьТекст(СчетЗатрат.ВидыСубконто.Получить(2).ВидСубконто);
			Иначе
				ОформлениеСтроки.Ячейки.ВидСубконто3.УстановитьТекст("");
			КонецЕсли;

		Иначе
			ОформлениеСтроки.Ячейки.ВидСубконто1.УстановитьТекст("");
			ОформлениеСтроки.Ячейки.ВидСубконто2.УстановитьТекст("");
			ОформлениеСтроки.Ячейки.ВидСубконто3.УстановитьТекст("");
		КонецЕсли;

	КонецЕсли;

	Если НЕ ОформлениеСтроки.Ячейки.Найти("ВидСубконтоНУ3") = НЕОПРЕДЕЛЕНО Тогда

		ОформлениеСтроки.Ячейки.ВидСубконтоНУ1.Видимость = ОтражатьВНалоговомУчете;
		ОформлениеСтроки.Ячейки.ВидСубконтоНУ2.Видимость = ОтражатьВНалоговомУчете;
		ОформлениеСтроки.Ячейки.ВидСубконтоНУ3.Видимость = ОтражатьВНалоговомУчете;

		Если НЕ ОбщегоНазначения.ЗначениеНеЗаполнено(СчетЗатратНУ) Тогда

			КоличествоСубконто = СчетЗатратНУ.ВидыСубконто.Количество();

			Если КоличествоСубконто > 0 Тогда
				ОформлениеСтроки.Ячейки.ВидСубконтоНУ1.УстановитьТекст( СчетЗатратНУ.ВидыСубконто.Получить(0).ВидСубконто);
			Иначе
				ОформлениеСтроки.Ячейки.ВидСубконтоНУ1.УстановитьТекст("");
			КонецЕсли;

			Если КоличествоСубконто > 1 Тогда
				ОформлениеСтроки.Ячейки.ВидСубконтоНУ2.УстановитьТекст(СчетЗатратНУ.ВидыСубконто.Получить(1).ВидСубконто);
			Иначе
				ОформлениеСтроки.Ячейки.ВидСубконтоНУ2.УстановитьТекст("");
			КонецЕсли;

			Если КоличествоСубконто > 2 Тогда
				ОформлениеСтроки.Ячейки.ВидСубконтоНУ3.УстановитьТекст(СчетЗатратНУ.ВидыСубконто.Получить(2).ВидСубконто);
			Иначе
				ОформлениеСтроки.Ячейки.ВидСубконтоНУ3.УстановитьТекст("");
			КонецЕсли;

		Иначе
			ОформлениеСтроки.Ячейки.ВидСубконтоНУ1.УстановитьТекст("");
			ОформлениеСтроки.Ячейки.ВидСубконтоНУ2.УстановитьТекст("");
			ОформлениеСтроки.Ячейки.ВидСубконтоНУ3.УстановитьТекст("");
		КонецЕсли;

	КонецЕсли;

	Если НЕ ОформлениеСтроки.Ячейки.Найти("Субконто1") = НЕОПРЕДЕЛЕНО Тогда

		ОформлениеСтроки.Ячейки.Субконто1.ТолькоПросмотр = ОформлениеСтроки.Ячейки.Субконто1.ТолькоПросмотр;
		ОформлениеСтроки.Ячейки.Субконто2.ТолькоПросмотр = ОформлениеСтроки.Ячейки.Субконто2.ТолькоПросмотр;
		ОформлениеСтроки.Ячейки.Субконто3.ТолькоПросмотр = ОформлениеСтроки.Ячейки.Субконто3.ТолькоПросмотр;

		ОформлениеСтроки.Ячейки.СубконтоНУ1.Видимость = ОтражатьВНалоговомУчете;
		ОформлениеСтроки.Ячейки.СубконтоНУ2.Видимость = ОтражатьВНалоговомУчете;
		ОформлениеСтроки.Ячейки.СубконтоНУ3.Видимость = ОтражатьВНалоговомУчете;

		ОформлениеСтроки.Ячейки.СубконтоНУ1.ТолькоПросмотр = ОформлениеСтроки.Ячейки.СубконтоНУ1.ТолькоПросмотр ИЛИ НЕ ОтражатьВНалоговомУчете;
		ОформлениеСтроки.Ячейки.СубконтоНУ2.ТолькоПросмотр = ОформлениеСтроки.Ячейки.СубконтоНУ2.ТолькоПросмотр ИЛИ НЕ ОтражатьВНалоговомУчете;
		ОформлениеСтроки.Ячейки.СубконтоНУ3.ТолькоПросмотр = ОформлениеСтроки.Ячейки.СубконтоНУ3.ТолькоПросмотр ИЛИ НЕ ОтражатьВНалоговомУчете;

	КонецЕсли;
	
КонецПроцедуры // НастроитьВидимостьЯчеекАналитикиЗатрат()

// Процедура удаляет из строки имен реквизитов, проверяемых на заполненность
// реквизиты, которые зависят от типа учета документа
//
// Параметры:
//		ДокОбъект - проверяемый документ
//		СтрокаРекв   - Строка с именами реквизитов, которые надо проверять на заполненность
//      УпрРеквизиты - строка, с именами реквизитов имеющих смысл
// 					   только в случае если документ отражается в упр.учете
//      БухРеквизиты - строка, с именами реквизитов имеющих смысл
// 					   только в случае если документ отражается в регл.(бух.) учете
//      НалРеквизиты - строка, с именами реквизитов имеющих смысл
// 					   только в случае если документ отражается в регл.(нал.) учете
//		ИмяТабЧасти  - имя проверяемой табл. части документа
//
Процедура НепроверятьРеквизитыПоТипуУчета(ДокОбъект, СтрокаРекв, Знач УпрРеквизиты, Знач БухРеквизиты, Знач НалРеквизиты, ИмяТабЧасти = "", СтруктураШапкиДокумента = Неопределено) Экспорт

	Стр = СтрЗаменить(СтрокаРекв, " ", "");
	СтруктРекв = Новый Структура(Стр);
	СтрокаРекв = "";

	БухРекв = СтрЗаменить(БухРеквизиты, " ", "");
	БухРекв = СтрЗаменить(БухРекв, Символы.ПС,  "");
	БухРекв = "," + СтрЗаменить(БухРекв, Символы.Таб, "") + ",";

	НалРекв = СтрЗаменить(НалРеквизиты, " ", "");
	НалРекв = СтрЗаменить(НалРекв, Символы.ПС,  "");
	НалРекв = "," + СтрЗаменить(НалРекв, Символы.Таб, "") + ",";

	Если СтруктураШапкиДокумента = Неопределено Тогда
		БухУчет = ИСТИНА;
		НалУчет = ?(ОбщегоНазначения.ЕстьРеквизитДокумента("ОтражатьВНалоговомУчете",      ДокОбъект.Метаданные()),ДокОбъект.ОтражатьВНалоговомУчете,Ложь);
	Иначе
		БухУчет = ИСТИНА;
		НалУчет = СтруктураШапкиДокумента.ОтражатьВНалоговомУчете;
	КонецЕсли;

	// Исключим из списка проверяемых реквизитов, те которые относятся к конкретному
	// виду учета и этот вид учета выключен
	Для Каждого Рекв Из СтруктРекв Цикл

		ИмяРекв = ?(ПустаяСтрока(ИмяТабЧасти), "", ИмяТабЧасти + ".") + Рекв.Ключ;

		Если Не БухУчет И СтрНайти(БухРекв, "," + ИмяРекв + ",") > 0 Тогда
			Продолжить;
		КонецЕсли;

		Если Не НалУчет И СтрНайти(НалРекв, "," + ИмяРекв + ",") > 0 Тогда
			Продолжить;
		КонецЕсли;

		СтрокаРекв = ?(ПустаяСтрока(СтрокаРекв), "", СтрокаРекв + ", ") + Рекв.Ключ;

	КонецЦикла;

КонецПроцедуры // НепроверятьРеквизитыПоТипуУчета()

// Функция определяет основную спецификациию для заданной
// номенклатуры на определенный момент.
//
Функция ОпределитьСпецификациюПоУмолчанию(Номенклатура, Момент) Экспорт
	
	Если ОбщегоНазначения.ЗначениеНеЗаполнено(Момент) Тогда // используем текущую дату
		Момент = ТекущаяДата();
	КонецЕсли;
	
	Отбор = Новый Структура;
	Отбор.Вставить("Номенклатура", Номенклатура);
	
	СпецификацияТекущая = РегистрыСведений.ОсновныеСпецификацииНоменклатуры.ПолучитьПоследнее(Момент,Отбор).СпецификацияНоменклатуры;
	
	Возврат СпецификацияТекущая;

КонецФункции // ОпределитьСпецификациюПоУмолчанию()

// Функция производит расчет сырья, необходимый для производства готовой
// продукции, указанной в документе - основание
Функция РассчитатьРасходСырьяПоСпецификации(ОснованиеСсылка, ДокументаОснованиеТЧ) Экспорт
	
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	СпецификацииНоменклатурыИсходныеКомплектующие.Номенклатура КАК Номенклатура,
		|	СпецификацииНоменклатурыИсходныеКомплектующие.Номенклатура.БазоваяЕдиницаИзмерения КАК ЕдиницаИзмерения,
		|	ВЫБОР
		|		КОГДА СпецификацииНоменклатуры.Количество = 0
		|			ТОГДА 0
		|		ИНАЧЕ ВложенныйЗапрос.КоличествоПродукции * СпецификацииНоменклатурыИсходныеКомплектующие.Количество / СпецификацииНоменклатуры.Количество
		|	КОНЕЦ КАК Количество
		|ИЗ
		|	(ВЫБРАТЬ
		|		ДокументОснования.Спецификация КАК Спецификация,
		|		СУММА(ДокументОснования.Количество) КАК КоличествоПродукции
		|	ИЗ
		|		Документ.ОтчетПроизводстваЗаСмену.Продукция КАК ДокументОснования
		|	ГДЕ
		|		ДокументОснования.Ссылка = &Ссылка
		|		И ДокументОснования.Спецификация <> &Спецификация
		|	
		|	СГРУППИРОВАТЬ ПО
		|		ДокументОснования.Спецификация) КАК ВложенныйЗапрос
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СпецификацииНоменклатуры КАК СпецификацииНоменклатуры
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СпецификацииНоменклатуры.ИсходныеКомплектующие КАК СпецификацииНоменклатурыИсходныеКомплектующие
		|			ПО СпецификацииНоменклатурыИсходныеКомплектующие.Ссылка = СпецификацииНоменклатуры.Ссылка
		|		ПО ВложенныйЗапрос.Спецификация = СпецификацииНоменклатуры.Ссылка";

		Запрос.УстановитьПараметр("Ссылка", ОснованиеСсылка);
		Запрос.УстановитьПараметр("Спецификация", Справочники.СпецификацииНоменклатуры.ПустаяСсылка());
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ОтчетПроизводстваЗаСмену.Продукция", ДокументаОснованиеТЧ);

		Возврат Запрос.Выполнить();
		
	КонецФункции
	