import React, { useState } from "react";
import { Button } from 'primereact/button';
import { Paginator } from 'primereact/paginator';
import { Dropdown } from 'primereact/dropdown';

    const [first, setFirst] = useState([0, 0, 0]);
    const [rows, setRows] = useState([10, 10, 10]);


    const onPageChange = (e, index) => {
        setFirst(first.map((f, i) => (index === i ? e.first : f)));
        setRows(rows.map((r, i) => (index === i ? e.rows : r)));
    };



    const leftContent = <Button type="button" icon="pi pi-star" className="p-button-outlined" />;
    const rightContent = <Button type="button" icon="pi pi-search" />;

    const standardTemplate = {
        layout: 'RowsPerPageDropdown CurrentPageReport PrevPageLink NextPageLink',
        RowsPerPageDropdown: (options) => {
            const dropdownOptions = [
                { label: 5, value: 5 },
                { label: 10, value: 10 },
                { label: 20, value: 20 },
                { label: 'All', value: options.totalRecords }
            ];

            return (
                <React.Fragment>
                    <span className="mx-1" style={{ color: 'var(--text-color)', userSelect: 'none' }}>
                        Items per page:{' '}
                    </span>
                    <Dropdown value={options.value} options={dropdownOptions} onChange={options.onChange} />
                </React.Fragment>
            );
        },
        CurrentPageReport: (options) => {
            return (
                <span style={{ color: 'var(--text-color)', userSelect: 'none', width: '120px', textAlign: 'center' }}>
                    {options.first} - {options.last} of {options.totalRecords}
                </span>
            );
        }
    };

export {standardTemplate}