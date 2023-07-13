import type { Station } from './types'
import { MapContainer, TileLayer, Marker, Popup, useMapEvents } from 'react-leaflet'
import { Icon, Marker as LeafletMarker } from 'leaflet'
import MarkerClusterGroup from 'react-leaflet-cluster'
import { useState, useRef } from 'react'
import { useForm } from 'react-hook-form'
import { saveStation } from './slice'

import { Noto_Color_Emoji } from 'next/font/google'
import styles from './index.module.css'
import { stat } from 'fs'

const emoji = Noto_Color_Emoji({ weight: '400', subsets: ['emoji'], preload: false })

interface Properties {
	stationsByCountry: { [country: string]: Station[] },
}

function flag(country: string) {
	const points = country
		.toUpperCase()
		.split('')
		.map((char) => 127397 + char.charCodeAt(0));
	return String.fromCodePoint(...points);
}

const train = new Icon({
	iconUrl: 'https://cdn-icons-png.flaticon.com/512/1702/1702305.png',
	iconSize: [24, 24],
	iconAnchor: [12, 12],
})

const stadium = new Icon({
	iconUrl: 'https://cdn-icons-png.flaticon.com/512/1540/1540530.png',
	iconSize: [24, 24],
	iconAnchor: [12, 12],
})

const pin = new Icon({
	iconUrl: 'https://cdn-icons-png.flaticon.com/512/2684/2684860.png',
	iconSize: [24, 24],
	iconAnchor: [0, 24],
})

interface MapFormProperties {
	clusters: { [country: string]: Station[] },
	setClusters: Function,
}

interface LoadingProperties {
	text: string,
}

const Loading = ({ text }: LoadingProperties) => {
	return (
		<>
			<img src="https://i.gifer.com/VAyR.gif" alt={text} width={16} height={16} /> {text}
		</>
	)
}

const MapForm = ({ clusters, setClusters }: MapFormProperties) => {
	const countries = Object.keys(clusters)
	const initialStation = {
		name: '',
		slug: '',
		country: 'GB',
		time_zone: 'Europe/London',
		latitude: 51.478,
		longitude: 0,
	} as Station
	const [station, setStation] = useState(initialStation)

	const marker = useRef(null)
	const {
		register,
		handleSubmit,
		formState: { isSubmitting, errors },
		setError,
	} = useForm({
		defaultValues: { ...initialStation },
	});

	useMapEvents({
		dblclick(event) {
			setStation({
				...station,
				latitude: event.latlng.lat,
				longitude: event.latlng.lng,
			})

			if (marker.current) {
				(marker.current as LeafletMarker).openPopup()
			}
		}
	})

	const save = async (data: object) => {
		const response = await saveStation({
			...data,
			latitude: station.latitude,
			longitude: station.longitude,
		} as Station)
		if (response.ok) {
			if (marker.current) {
				const current = (marker.current as LeafletMarker)
				current.closePopup()
			}
			const record = await response.json() as Station
			console.log('Response:', record)
			setStation({ ...initialStation });
			const cluster = clusters[record.country] as Station[]
			cluster.push(record)

			setClusters({
				...clusters,
				[record.country]: [...cluster],
			})
		} else if (response.status == 400) {
			const errors: { [field: string]: string } = await response.json()
			for (const [field, message] of Object.entries(errors)) {
				setError(field, { type: 'custom', message })
			}
		} else {
			console.error('Unknown error:', await response.text())
		}

		return response
	}

	return (
		<Marker ref={marker} position={[station.latitude, station.longitude]} icon={pin}>
			<Popup>
				<form id="popup-add-form" className={`${styles.form}`} method="POST" onSubmit={handleSubmit(save)}>
					<h3>Add New Marker</h3>
					<label htmlFor="name">Name: </label>
					<input type="text" required {...register('name')} />
					<div className={styles.error}>{errors.name?.message}</div>
					<div className={styles.location}>
						<div>
							<label htmlFor="latitude">Latitude: </label>
							<input type="text" name="latitude" value={station.latitude.toFixed(5)} disabled />
						</div>
						<div>
							<label htmlFor="longitude">Longitude: </label>
							<input type="text" name="longitude" value={station.longitude.toFixed(5)} disabled />
						</div>
					</div>
					<label htmlFor="slug">Slug: </label>
					<input type="text" {...register('slug')} />
					<div className={styles['country-time']}>
						<div className={styles.country}>
							<label htmlFor="country">Country: </label>
							<select className={emoji.className} {...register('country')}>
								{countries.map((country) =>
									<option className={emoji.className} key={country} value={country}>{flag(country)}</option>)}
							</select>
						</div>
						<div className={styles.time}>
							<label htmlFor="time_zone">Timezone: </label>
							<input type="text" {...register('time_zone')} />
						</div>
					</div>
					<button type="submit" disabled={isSubmitting}>
						{isSubmitting ? <Loading text="Saving..." /> : 'Save'}
					</button>
				</form>
			</Popup>
		</Marker >
	)
}

const GeoFootball = ({ stationsByCountry }: Properties) => {
	const openStreetMaps = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
	const copyright = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'

	const [clusters, setClusters] = useState(stationsByCountry)

	return (
		<MapContainer className={styles.map} center={[51.505, 0]} zoom={5} scrollWheelZoom doubleClickZoom={false}>
			<TileLayer attribution={copyright} url={openStreetMaps} />
			<MapForm clusters={clusters} setClusters={setClusters} />
			{Object.entries(clusters).map(([country, stations]) =>
				<MarkerClusterGroup key={country} chunkedLoading>
					{(stations as Station[]).map((station: Station) =>
						<Marker key={`train-${station.id}`} position={[station.latitude, station.longitude]} icon={train}>
							<Popup key={`train-popup-${station.id}`}>
								<div className={styles.popup}>
									<h3>{station.name}</h3>
									<dl>
										<dt>Country: </dt><dd>{country} <span className={emoji.className}>{flag(country)}</span></dd>
										<dt>Position: </dt><dd>{station.latitude.toFixed(5)}, {station.longitude.toFixed(5)}</dd>
										<dt>Timezone: </dt><dd>{station.time_zone}</dd>
									</dl>
									<p>{station.info_en}</p>
								</div>
							</Popup>
						</Marker>
					)}
				</MarkerClusterGroup>
			)}

		</MapContainer>
	)
}

export default GeoFootball
