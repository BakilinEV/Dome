
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Пользователь1С = Документы.Заявка.Пользователь1С();
	
	ТолькоПросмотр = Объект.Проведен И Не Пользователь1С;
	
	Элементы.ТоварыСтатус.Видимость = Объект.Проведен;
	
	Элементы.ТоварыИдентификаторСтроки.Видимость = Пользователь1С;
	
	Если Не ТолькоПросмотр Тогда
		
		Адрес = ПолучитьАдресПоставки();
		Если ПустаяСтрока(Объект.АдресПоставки) Тогда
			Объект.АдресПоставки = Адрес;
		КонецЕсли;
		
		Список = Элементы.СрокПоставки.СписокВыбора;
		Список.Добавить(НачалоДня(ТекущаяДата()), "Сегодня"    );
		Список.Добавить(Список[0].Значение+86400, "Завтра"     );
		Список.Добавить(Список[1].Значение+86400, "Послезавтра");
		
	КонецЕсли;
	
	ЗапаснаяЧасть = РегистрыСведений.ксНастройкиСистемы.ПолучитьНастройку("ВидНомЗЧ");
	ОсновнойСклад = БухгалтерскийУчетПереопределяемый.ПолучитьЗначениеПоУмолчанию("ОсновнойСклад");
	
	Элементы.ТоварыОстаток.Заголовок = "Остаток"+Символы.ПС+?(ОсновнойСклад.Пустая(), "по организации", ОсновнойСклад);
	
	ОбновитьОстатокНоменклатуры();
	
	ОбновитьСтатусыСтрок();
	
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область КопированиеВставкаСтрокЧерезБуферОбмена

&НаСервере
Процедура СкопироватьСтрокиНаСервере(ИмяТаблицы="Товары")
	
	ОбщегоНазначения.СкопироватьСтрокиВБуферОбмена(Объект[ИмяТаблицы], 
		Элементы[ИмяТаблицы].ВыделенныеСтроки, Объект.Ссылка.Метаданные().Имя);

КонецПроцедуры

&НаСервере
Функция ВставитьСтрокиНаСервере(ИмяТаблицы="Товары")
	
	ПараметрыВставки = ОбработкаТабличныхЧастей.ПолучитьПараметрыВставкиДанныхИзБуфераОбмена(Объект.Ссылка, ИмяТаблицы);
	ОпределитьСписокСвойствДляВставкиИзБуфера(ПараметрыВставки);
	ОбработкаВыбораПодборВставкаИзБуфераНаСервере(ПараметрыВставки, ПараметрыВставки.ИмяТаблицы);
	
	Возврат ПараметрыВставки.КоличествоДобавленныхСтрок;
	
КонецФункции

&НаСервере
Процедура ОпределитьСписокСвойствДляВставкиИзБуфера(ПараметрыВставки)

	СписокСвойств = Новый Массив;
	СписокСвойств.Добавить("Номенклатура");
	СписокСвойств.Добавить("ЕдиницаИзмерения");
	СписокСвойств.Добавить("Количество");
	
	ПараметрыВставки.СписокСвойств = ОбработкаТабличныхЧастей.ПолучитьСписокСвойствИмеющихсяВТаблицеДанных(
		ПараметрыВставки.Данные, СписокСвойств);
	
КонецПроцедуры
	
&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьКомандыВставки(Форма, Доступность)

	Доступность = Не Форма.ТолькоПросмотр И Доступность;
	Элементы = Форма.Элементы;
	Элементы.ТоварыВставитьСтроки.Доступность					 = Доступность;
	Элементы.ТоварыКонтекстноеМенюВставитьСтроки.Доступность	 = Доступность;

КонецПроцедуры

&НаКлиенте
Процедура СкопироватьСтроки(Команда)
	
	КоличествоСтрок = Элементы.Товары.ВыделенныеСтроки.Количество();
	Если КоличествоСтрок = 0 Тогда
		Возврат;
	КонецЕсли;
	
	СкопироватьСтрокиНаСервере();
	ОбработкаТабличныхЧастейКлиент.ОповеститьОКопированииСтрокВБуферОбмена(ЭтотОбъект, КоличествоСтрок);
	
КонецПроцедуры

&НаКлиенте
Процедура ВставитьСтроки(Команда)
	
	КоличествоСтрок = ВставитьСтрокиНаСервере();
	ОбработкаТабличныхЧастейКлиент.ОповеститьОВставкеСтрокИзБуфераОбмена(ЭтотОбъект, КоличествоСтрок);
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаВыбораПодборВставкаИзБуфераНаСервере(ВыбранноеЗначение, ИмяТаблицы)

	//ПараметрыОбъекта = Неопределено;
	//ЗаполнитьПараметрыОбъектаДляЗаполненияДобавленныхКолонок(ЭтотОбъект, ПараметрыОбъекта);

	//ДобавленныеСтроки = РеализацияТоваровУслугФормы.ОбработкаВыбораПодборВставкаИзБуфера(ЭтотОбъект, ВыбранноеЗначение, ИмяТаблицы);
	//
	//СписокСчетов = Новый Массив;
	//Для Каждого СтрокаТаблицы Из ДобавленныеСтроки.Товары Цикл
	//	Если ЗначениеЗаполнено(СтрокаТаблицы.СчетНаОплатуПокупателю) Тогда
	//		СписокСчетов.Добавить(СтрокаТаблицы.СчетНаОплатуПокупателю);
	//	КонецЕсли; 
	//КонецЦикла;
	//
	//РеквизитыСчетовНаОплату = ОбщегоНазначения.ЗначенияРеквизитовОбъектов(СписокСчетов, "Номер, Дата");
	//
	//Для Каждого СтрокаТаблицы Из ДобавленныеСтроки.Товары Цикл
	//	ЗаполнитьДобавленныеКолонкиСтрокиТаблицыТовары(ЭтотОбъект, СтрокаТаблицы, РеквизитыСчетовНаОплату, ПараметрыОбъекта);
	//КонецЦикла;
	//
	//ЗаполнитьПризнакМаркируемойПродукцииТаблицыТовары(ДобавленныеСтроки.Товары, ИспользоватьКонтрольныеЗнакиГИСМ, ВестиУчетМаркируемойПродукцииИСМП);
	//
	//РеализацияТоваровУслугФормыКлиентСервер.ЗаполнитьРеквизитыСчетНаОплату(ЭтотОбъект);
	//
	//РеализацияТоваровУслугФормы.ПриДобавленииСчетов(ЭтотОбъект, СписокСчетов);
	//
	//ОбновитьИтоги(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти // КопированиеВставкаСтрокЧерезБуферОбмена

#Область АдресПоставки

&НаСервере
Функция ПолучитьАдресПоставки()
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗЛИЧНЫЕ ПЕРВЫЕ 5
	|	Заявка.АдресПоставки,
	|	Заявка.АдресПоставки КАК Представление,
	|	СУММА(1) КАК Приоритет,
	|	1 КАК Порядок
	|ИЗ
	|	Документ.Заявка КАК Заявка
	|ГДЕ
	|	Заявка.Организация = &Организация
	|	И Заявка.Ссылка <> &Ссылка
	|	И Заявка.АдресПоставки <> """"
	|	И Заявка.Ответственный = &Ответственный
	|
	|СГРУППИРОВАТЬ ПО
	|	Заявка.АдресПоставки,
	|	Заявка.АдресПоставки
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	&АдресПоставки,
	|	""──────────────────────────────────────────────────"",
	|	0,
	|	2
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ РАЗЛИЧНЫЕ ПЕРВЫЕ 5
	|	Заявка.АдресПоставки,
	|	Заявка.АдресПоставки,
	|	СУММА(1),
	|	3
	|ИЗ
	|	Документ.Заявка КАК Заявка
	|ГДЕ
	|	Заявка.Организация = &Организация
	|	И Заявка.Ссылка <> &Ссылка
	|	И Заявка.АдресПоставки <> """"
	|	И Заявка.Ответственный <> &Ответственный
	|
	|СГРУППИРОВАТЬ ПО
	|	Заявка.АдресПоставки,
	|	Заявка.АдресПоставки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Порядок,
	|	Приоритет УБЫВ"
	);
	
	Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	Запрос.УстановитьПараметр("Ответственный", Объект.Ответственный);
	Запрос.УстановитьПараметр("АдресПоставки", Объект.АдресПоставки);
	
	Список = Элементы.АдресПоставки.СписокВыбора;
	Список.Очистить();
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Список.Добавить(Выборка.АдресПоставки, Выборка.Представление);
	КонецЦикла;
	
	Возврат ?(Список.Количество()>0, Список[0].Значение, "");
	
КонецФункции

&НаКлиенте
Процедура АдресПоставкиПриИзменении(Элемент)
	
	ПолучитьАдресПоставки();
	
КонецПроцедуры

#КонецОбласти // АдресПоставки

&НаКлиенте
Процедура СрокПоставкиПриИзменении(Элемент)
	
	Объект.СрокПоставки = Макс(Объект.СрокПоставки, ТекущаяДата());
	
КонецПроцедуры

#Область ВспомогательныеФункции

&НаСервереБезКонтекста
Функция НайтиНоменклатуруПоКоду(КодПоиска)
	
	Возврат Справочники.Номенклатура.НайтиПоКоду(КодПоиска);
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьЗаводскойНомер(ОсновноеСредство)
	
	Возврат ВРЕГ(СокрЛП(ОсновноеСредство.ЗаводскойНомер));
	
КонецФункции

&НаКлиенте
Функция УдалитьИзКомментарияЗаводскойНомер(Знач Комментарий, ЗаводскойНомер)
	
	Комментарий = СтрЗаменить(Комментарий, "VIN:", "");
	Комментарий = СтрЗаменить(Комментарий, ЗаводскойНомер, "");
	Комментарий = СокрЛП(Комментарий);
	Пока Найти(Комментарий, "  ") > 0 Цикл
		Комментарий = СтрЗаменить(Комментарий, "  ", "");
	КонецЦикла;
	
	Возврат Комментарий;
	
КонецФункции

&НаКлиенте
Функция ОбновитьСписокВыбораКомментариев()
	
	СписокВыбора = Элементы.ТоварыКомментарий.СписокВыбора;
	
	ТекущиеДанные = Элементы.Товары.ТекущиеДанные;
	Идентификатор = ТекущиеДанные.ПолучитьИдентификатор();
	ТекущаяСтрока = Объект.Товары.НайтиПоИдентификатору(Идентификатор);
	
	СписокВыбора.Очистить();
	
	Для Каждого СтрокаТовара Из Объект.Товары Цикл
		
		ЗаводскойНомер = ПолучитьЗаводскойНомер(СтрокаТовара.ОсновноеСредство);
		Комментарий = УдалитьИзКомментарияЗаводскойНомер(СтрокаТовара.Комментарий, ЗаводскойНомер);
		
		Если СтрокаТовара = ТекущаяСтрока И Не ПустаяСтрока(ЗаводскойНомер) Тогда
			
			СписокВыбора.Вставить(0, "VIN: "+ЗаводскойНомер);
			Если Не ПустаяСтрока(Комментарий) Тогда
				СписокВыбора.Вставить(1, "VIN: "+ЗаводскойНомер+" "+Комментарий);
				СписокВыбора.Вставить(2, Комментарий+" VIN: "+ЗаводскойНомер);
				СписокВыбора.Вставить(3, Комментарий);
			КонецЕсли;
			
		ИначеЕсли Не ПустаяСтрока(Комментарий) Тогда
			
			Если СписокВыбора.НайтиПоЗначению(Комментарий) = Неопределено Тогда
				СписокВыбора.Добавить(Комментарий);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецФункции

#КонецОбласти // ВспомогательныеФункции

#Область ВспомогательныеПоискаПоКаталожномуНомеру

// Функция проверяет наличие в строке цифр
//
// Параметры
//  СтрокаПроверки - Строка для проверки наличия цифр
// Возвращаемое значение:
//   Булево
//
&НаСервереБезКонтекста
Функция ВСтрокеЕстьЦифры(Знач СтрокаПроверки)
	
	Для й = 1 По СтрДлина(СтрокаПроверки) Цикл
		КодСимвола = КодСимвола(Сред(СтрокаПроверки, й, 1));
		Если (48 <= КодСимвола И КодСимвола <= 57) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции // ВСтрокеЕстьЦифры

&НаСервере
Функция ПолучитьКаталожныйНомер(Номенклатура)
	
	Списком = Истина;
	Список = НОвый СписокЗначений;
	//Список = ТекущаяСтрока.Артикул.СписокВыбора;
	//Список.Очистить();
	
	Если Номенклатура.СтатьяЗатрат.Код <> "2.4.1" Тогда
		Возврат "";
	КонецЕсли;
	
	Если Не ПустаяСтрока(Номенклатура.Артикул) Тогда
		Если Списком Тогда
			Список.Добавить(Номенклатура.Артикул);
		Иначе
			Возврат СокрЛП(Номенклатура.Артикул);
		КонецЕсли;
	КонецЕсли;
	
	ЧастиСтроки = СтрЗаменить(СокрЛП(Номенклатура.Наименование), " ", Символы.ПС);
	
	Для й=-СтрЧислоСтрок(ЧастиСтроки) По -1 Цикл
		
		Строка = СтрПолучитьСтроку(ЧастиСтроки, -й);
		Если ВСтрокеЕстьЦифры(Строка) Тогда
			Если Списком Тогда
				Список.Добавить(Строка);
			Иначе
				Возврат Строка;
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Список;
	
КонецФункции

&НаСервереБезКонтекста
Функция НайтиНоменклатуруПоСтроке(Знач СтрокаПоиска)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	СправочникНоменклатура.Наименование КАК Наименование,
	|	СправочникНоменклатура.Ссылка КАК Ссылка,
	|	СправочникНоменклатура.Код КАК Код,
	|	СправочникНоменклатура.Артикул КАК Артикул,
	|	СправочникНоменклатура.Наименование ПОДОБНО &СтрокаПоиска КАК НайденоПоНаименованию,
	|	СправочникНоменклатура.Артикул ПОДОБНО &СтрокаПоиска КАК НайденоПоАртикулу,
	|	СправочникНоменклатура.Код ПОДОБНО &СтрокаПоиска КАК НайденоПоКоду,
	|	ВЫБОР
	|		КОГДА СправочникНоменклатура.Код ПОДОБНО &СтрокаПоиска
	|			ТОГДА СправочникНоменклатура.Код
	|		КОГДА СправочникНоменклатура.Артикул ПОДОБНО &СтрокаПоиска
	|			ТОГДА СправочникНоменклатура.Артикул
	|		КОГДА СправочникНоменклатура.Наименование ПОДОБНО &СтрокаПоиска
	|			ТОГДА СправочникНоменклатура.Наименование
	|		ИНАЧЕ """"""""
	|	КОНЕЦ КАК ТекстСовпадения,
	|	ЕСТЬNULL(ДопРеквизитыНоменклатуры.ЭтоЮралс, ЛОЖЬ) КАК ЭтоЮралс
	|ИЗ
	|	Справочник.Номенклатура КАК СправочникНоменклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДопРеквизитыНоменклатуры КАК ДопРеквизитыНоменклатуры
	|		ПО (СправочникНоменклатура.Ссылка = ДопРеквизитыНоменклатуры.Номенклатура)
	|ГДЕ
	|	НЕ СправочникНоменклатура.ПометкаУдаления
	|	И (СправочникНоменклатура.Наименование ПОДОБНО &СтрокаПоиска
	|			ИЛИ СправочникНоменклатура.Артикул ПОДОБНО &СтрокаПоиска
	|			ИЛИ СправочникНоменклатура.Код ПОДОБНО &СтрокаПоиска)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ЭтоЮралс УБЫВ"
	);
	
	Запрос.УстановитьПараметр("СтрокаПоиска", "%"+СтрЗаменить(СтрокаПоиска," ", "%")+"%");
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат РезультатЗапроса.Выбрать();
	
КонецФункции

Функция ПолучитьПредполагаемыйКаталожныйНомер(Номенклатура, Знач Текст)
	
	Список = Новый Массив;
	Номера = ПолучитьКаталожныйНомер(Номенклатура);
	
	Строки = СтрЗаменить(СокрЛП(Текст), " ", Символы.ПС);
	Для й=1 По СтрЧислоСтрок(Строки) Цикл
		
		СтрокаПоиска = СтрПолучитьСтроку(Строки, й);
		
		Для Каждого Элемент Из Номера Цикл
			Если Найти(ВРЕГ(Элемент.Значение), ВРЕГ(СтрокаПоиска))>0 Тогда
				Список.Добавить(Элемент.Значение);
			КонецЕсли;
		КонецЦикла;
		
	КонецЦикла;
	
	Для Каждого Строка Из Список Цикл
		Если ВСтрокеЕстьЦифры(Строка) Тогда
			Возврат Строка;
		КонецЕсли;
	КонецЦикла;
	
	Возврат "";
	
КонецФункции

Функция ПолучитьКонецСтроки(Строка, Префикс)
	
	Позиция = Найти(ВРЕГ(Строка), ВРЕГ(Префикс));
	Если Позиция = 0 Тогда
		Возврат Префикс;
	Иначе
		Возврат Сред(Строка, Позиция);
	КонецЕсли;
	
КонецФункции

#КонецОбласти //ВспомогательныеПоискаПоКаталожномуНомеру

#Область ОбработчикиСобытийЭлементовТаблицыФормыТовары

&НаКлиенте
Процедура ТоварыНоменклатураКодПриИзменении(Элемент)
	
	НайденныйЭлемент = НайтиНоменклатуруПоКоду(СокрЛП(Элемент.Значение));
	
	Если НайденныйЭлемент.ПометкаУдаления Тогда
		Сообщить("Элемент помечен на удаление!"+Символы.ПС+"Введите другой код");
		Возврат;
	КонецЕсли;
	
	Элементы.Товары.ТекущиеДанные.Номенклатура = НайденныйЭлемент;
	ПриИзмененииНоменклатуры(Неопределено);
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЕдиницаИзмеренияНоменклатуры(Номенклатура)
	
	Возврат Номенклатура.ЕдиницаИзмерения;
	
КонецФункции

&НаКлиенте
Процедура ТоварыНоменклатураПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Товары.ТекущиеДанные;
	ТекущиеДанные.ЕдиницаИзмерения = ЕдиницаИзмеренияНоменклатуры(ТекущиеДанные.Номенклатура);
	
	ОбновитьСписокВыбораКаталожныхНомеров(Истина);
	ОбновитьОстатокНоменклатуры(ТекущиеДанные.Номенклатура);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьОстатокНоменклатуры(Номенклатура=Неопределено)
	
	Если Объект.Товары.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыОтбора = Новый Структура;
	Если Номенклатура <> Неопределено Тогда
		ПараметрыОтбора.Вставить("Номенклатура", Номенклатура);
	КонецЕсли;
	
	НайденныеСтроки = Объект.Товары.НайтиСтроки(ПараметрыОтбора);
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Номенклатура,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.Субконто3, ""НЕТ НА ОСТАТКЕ"") КАК Склад,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.КоличествоОстаток, 0) КАК Остаток
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный.Остатки(
	|				КОНЕЦПЕРИОДА(&НаДату, ДЕНЬ),
	|				Счет В ИЕРАРХИИ (ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.Материалы), ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ГотоваяПродукция)),
	|				,
	|				Субконто1 В (&Номенклатура)
	|					И ВЫБОР
	|						КОГДА &Склад = ЗНАЧЕНИЕ(Справочник.Склады.ПустаяСсылка)
	|							ТОГДА ИСТИНА
	|						ИНАЧЕ Субконто3 = &Склад
	|					КОНЕЦ) КАК ХозрасчетныйОстатки
	|		ПО Номенклатура.Ссылка = ХозрасчетныйОстатки.Субконто1
	|ГДЕ
	|	Номенклатура.Ссылка В(&Номенклатура)"
	);
	
	Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
	Запрос.УстановитьПараметр("Склад" , БухгалтерскийУчетПереопределяемый.ПолучитьЗначениеПоУмолчанию("ОсновнойСклад"));
	Запрос.УстановитьПараметр("Номенклатура", Объект.Товары.Выгрузить(НайденныеСтроки).ВыгрузитьКолонку("Номенклатура"));
	
	ТаблицаОстатков = Запрос.Выполнить().Выгрузить();
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Номенклатура,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.Субконто3, ""НЕТ НА ОСТАТКЕ"") КАК Склад,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.КоличествоОстаток, 0) КАК Остаток
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный.Остатки(
	|				КОНЕЦПЕРИОДА(&НаДату, ДЕНЬ),
	|				Счет В ИЕРАРХИИ (ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.Материалы), ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ГотоваяПродукция)),
	|				,
	|				Субконто1 В (&Номенклатура)
	|					И ВЫБОР
	|						КОГДА &Склад = ЗНАЧЕНИЕ(Справочник.Склады.ПустаяСсылка)
	|							ТОГДА ИСТИНА
	|						ИНАЧЕ Субконто3 = &Склад
	|					КОНЕЦ) КАК ХозрасчетныйОстатки
	|		ПО Номенклатура.Ссылка = ХозрасчетныйОстатки.Субконто1
	|ГДЕ
	|	Номенклатура.Ссылка В(&Номенклатура)"
	);
	
	Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
	Запрос.УстановитьПараметр("Склад" , БухгалтерскийУчетПереопределяемый.ПолучитьЗначениеПоУмолчанию("ОсновнойСклад"));
	Запрос.УстановитьПараметр("Номенклатура", Объект.Товары.Выгрузить(НайденныеСтроки).ВыгрузитьКолонку("Номенклатура"));
	
	ТаблицаОстатков = Запрос.Выполнить().Выгрузить();
	
	ДанныеОстаток = Объект.Товары.Выгрузить();
	ДанныеОстаток.ЗаполнитьЗначения(0, "Остаток");
	Объект.Товары.Загрузить(ДанныеОстаток);
	
	Для Каждого СтрокаОстатка Из ТаблицаОстатков Цикл
		
		ПараметрыОтбора = Новый Структура("Номенклатура", СтрокаОстатка.Номенклатура);
		НайденныеСтроки = Объект.Товары.НайтиСтроки(ПараметрыОтбора);
		Для Каждого СтрокаТовара Из НайденныеСтроки Цикл
			СтрокаТовара.Остаток = СтрокаОстатка.Остаток;
		КонецЦикла;
		
	КонецЦикла;
	
	Для Каждого СтрокаТовара Из НайденныеСтроки Цикл
		
		СтрокаОстатка = ТаблицаОстатков.Найти(СтрокаТовара.Номенклатура, "Номенклатура");
		СтрокаТовара.Остаток = ?(СтрокаОстатка=Неопределено, 0, СтрокаОстатка.Остаток);
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСтатусыСтрок()
	
	Если Объект.Товары.Количество()=0 Или Не Элементы.ТоварыСтатус.Видимость Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТовара Из Объект.Товары Цикл
		СтрокаТовара.Статус = РегистрыСведений.ЗаявкаСтатусы.ПолучитьСтатус(СтрокаТовара.ИдентификаторСтроки);
	КонецЦикла;
	
КонецПроцедуры

#Область Артикул

&НаСервереБезКонтекста
Функция ПолучитьСписокВыбораКаталожныхНомеровСервер(Номенклатура, ЗапаснаяЧасть=Неопределено)
	
	СписокВыбора = Новый Массив;
	
	Если Не ПустаяСтрока(Номенклатура.Артикул) Тогда
		СписокВыбора.Добавить(СокрЛП(Номенклатура.Артикул));
	КонецЕсли;
	
	Если Номенклатура.ВидНоменклатуры <> ЗапаснаяЧасть Тогда
		Возврат СписокВыбора;
	КонецЕсли;
	
	ЧастиСтроки = СтрЗаменить(СокрЛП(Номенклатура.Наименование), " ", Символы.ПС);
	
	Для й=-СтрЧислоСтрок(ЧастиСтроки) По -1 Цикл
		
		Строка = СтрПолучитьСтроку(ЧастиСтроки, -й);
		Если ВСтрокеЕстьЦифры(Строка) Тогда
			СписокВыбора.Добавить(Строка);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СписокВыбора;
	
КонецФункции

&НаКлиенте
Процедура ОбновитьСписокВыбораКаталожныхНомеров(УстановитьАртикул=Ложь)
	
	ТекущиеДанные = Элементы.Товары.ТекущиеДанные;
	
	СписокВыбора = Элементы.ТоварыНоменклатураАртикул.СписокВыбора;
	СписокВыбора.ЗагрузитьЗначения(ПолучитьСписокВыбораКаталожныхНомеровСервер(ТекущиеДанные.Номенклатура, ЗапаснаяЧасть));
	
	Если УстановитьАртикул И ПустаяСтрока(ТекущиеДанные.Артикул) И СписокВыбора.Количество()>0 Тогда
		ТекущиеДанные.Артикул = СписокВыбора[0].Значение;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти // Артикул

&НаСервере
Процедура ПриИзмененииНоменклатуры(Идентификатор)
	
	ТекущиеДанные = Объект.Товары.НайтиПоИдентификатору(Идентификатор);
	
	Номенклатура = ТекущиеДанные.Номенклатура;
	ТекущиеДанные.ЕдиницаИзмерения = Номенклатура.ЕдиницаИзмерения;
	
КонецПроцедуры // ПриИзмененииНоменклатуры()

#Область ОсновноеСредство

&НаКлиенте
Процедура ТоварыОсновноеСредствоПриИзменении(Элемент)
	
	ОбновитьСписокВыбораКомментариев();
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыОсновноеСредствоОчистка(Элемент, СтандартнаяОбработка)
	
	ТекущиеДанные = Элементы.Товары.ТекущиеДанные;
	ТекущиеДанные.Комментарий = УдалитьИзКомментарияЗаводскойНомер(ТекущиеДанные.Комментарий, ПолучитьЗаводскойНомер(ТекущиеДанные.ОсновноеСредство));
	
КонецПроцедуры

#КонецОбласти // ОсновноеСредство

&НаКлиенте
Процедура ТоварыПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Данные = Элемент.ТекущиеДанные;
	Если НоваяСтрока И Копирование Тогда
		
		Данные.Приоритет           = Ложь;
		Данные.Количество          = 0;
		Данные.ИдентификаторСтроки = "";
		
		Если Найти("|ТоварыНоменклатураКод|ТоварыНоменклатураАртикул|ТоварыНоменклатура|", ИмяВыделеннойКолонки) = 0 Тогда
			Данные.ЕдиницаИзмерения = Неопределено;
			Данные.Номенклатура     = Неопределено;
			Данные.Артикул          = "";
		КонецЕсли;
		
		Если Найти("|ТоварыОсновноеСредствоКод|ТоварыОсновноеСредство|ТоварыКомментарий|", ИмяВыделеннойКолонки) = 0 Тогда
			Данные.ОсновноеСредство = Неопределено;
			Данные.Комментарий      = "";
		КонецЕсли;
		
	Иначе
		
		ОбновитьСписокВыбораКомментариев();
		ОбновитьСписокВыбораКаталожныхНомеров();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПриАктивизацииПоля(Элемент)
	
	Если ИмяТекущейКолонки <> ИмяВыделеннойКолонки Тогда
		ИмяВыделеннойКолонки = ИмяТекущейКолонки;
	КонецЕсли;
	
	ИмяТекущейКолонки = Элемент.ТекущийЭлемент.Имя;
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыНоменклатураАртикулАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	//ПараметрыПолученияДанных.СтрокаПоиска = СокрЛП(Текст);
	ПараметрыПолученияДанных.СпособПоискаСтроки = СпособПоискаСтрокиПриВводеПоСтроке.ЛюбаяЧасть;
	
	//СтандартнаяОбработка = Ложь;
	
	//Номенклатура = Элементы.Товары.ТекущиеДанные.Номенклатура;
	//
	//Если Номенклатура.Пустая() Тогда
	//
	//	СтрПоиска = СокрЛП(Текст);
	//	Результат = НайтиНоменклатуруПоСтроке(СтрПоиска);
	//	
	//	Если Результат <> Неопределено И Результат.Количество()=1 Тогда
	//		
	//		Результат.Следующий();
	//		ТекстАвтоПодбора = ПолучитьКонецСтроки(Результат.ТекстСовпадения, СтрПоиска);
	//		
	//	КонецЕсли;
	//	
	//ИначеЕсли Не ПустаяСтрока(Текст) Тогда
	//	
	//	КонецСтроки = ПолучитьКонецСтроки(Номенклатура.Наименование, Текст);
	//	
	//	Если Найти(КонецСтроки, " ") > 0 Тогда // несколько слов
	//		КонецСтроки = СтрЗаменить(Сред(КонецСтроки, СтрДлина(Текст)+1), " ", Символы.ПС);
	//		КонецСтроки = Текст+СтрПолучитьСтроку(КонецСтроки, 1);
	//	КонецЕсли;
	//	
	//	ТекстАвтоПодбора = КонецСтроки;
	//	
	//КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыНоменклатураАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	ПараметрыПолученияДанных.ПолнотекстовыйПоиск = ПолнотекстовыйПоискПриВводеПоСтроке.Использовать;
	ПараметрыПолученияДанных.СпособПоискаСтроки  = СпособПоискаСтрокиПриВводеПоСтроке.ЛюбаяЧасть;
	//ПараметрыПолученияДанных.СтрокаПоиска = СокрЛП(Текст);
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыОсновноеСредствоАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	ПараметрыПолученияДанных.ПолнотекстовыйПоиск = ПолнотекстовыйПоискПриВводеПоСтроке.Использовать;
	ПараметрыПолученияДанных.СпособПоискаСтроки  = СпособПоискаСтрокиПриВводеПоСтроке.ЛюбаяЧасть;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьИсториюСтатусов(ИдентификаторСтроки)
	
	Возврат РегистрыСведений.ЗаявкаСтатусы.ИсторияСтатусов(ИдентификаторСтроки);
	
КонецФункции

&НаКлиенте
Процедура ТоварыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Поле = Элементы.ТоварыСтатус Тогда
		Список = ПолучитьИсториюСтатусов(Элемент.ТекущиеДанные.ИдентификаторСтроки);
		ПоказатьВыборИзСписка(Новый ОписаниеОповещения, Список);
		//ПоказатьВыборИзМеню(Новый ОписаниеОповещения, Список);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовТаблицыФормыТовары
