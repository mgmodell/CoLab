import React from 'react'

type Props = {
}

export default function EditorToolbar(props: Props) {
    return (
        <div id='toolbar'>
            <select className='ql-size'>
                <option value='small'></option>
                <option value='large'></option>
            </select>
            <select className='ql-header'>
                <option value='1'></option>
                <option value='2'></option>
            </select>
            <select className='ql-font'>
                <option value='serif'></option>
                <option value='monospace'></option>
            </select>
            <button className='ql-separator'></button>

            <button className='ql-bold'></button>
            <button className='ql-italic'></button>
            <button className='ql-underline'></button>
            <button className='ql-strike'></button>
            <button className='ql-separator'></button>

            <button className='ql-script' value='sub'></button>
            <button className='ql-script' value='super'></button>
            <button className='ql-separator'></button>

            <button className='ql-list' value='ordered'></button>
            <button className='ql-list' value='bullet'></button>
            <button className='ql-separator'></button>

            <select className='ql-color'></select>
            <select className='ql-background'></select>
            <button className='ql-separator'></button>

            <select className='ql-align'>
                <option value='center'></option>
                <option value='right'></option>
                <option value='justify'></option>
            </select>
            <button className='ql-indent' value='-1'></button>
            <button className='ql-indent' value='+1'></button>
            <button className='ql-separator'></button>

            <button className='ql-link'></button>
            <button className='ql-code'></button>
            <button className='ql-blockquote'></button>
            <button className='ql-separator'></button>

            <button className='ql-formula'></button>
            <button className='ql-separator'></button>

            <button className='ql-clean'></button>

        </div>
    )
}